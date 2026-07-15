{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.cfg.kvm;

  # ───────── Helpers ─────────

  # Resolve a guest's storage directory.
  storageDir =
    name: guest:
    if guest.storagePath != null then
      "${cfg.host.storage.persistentPath or cfg.host.storage.statePath}/${guest.storagePath}"
    else
      "${cfg.host.storage.statePath}/qemu/${name}";

  # Resolve a disk path — relative name joins with storage dir + format extension,
  # absolute paths are used as-is.
  resolveDiskPath =
    sdir: disk: if hasPrefix "/" disk.path then disk.path else "${sdir}/${disk.path}.${disk.format}";

  # Convert Proxmox/Linux BDF "0000:01:00.0" to libvirt address XML.
  pciBdfToXml =
    bdf:
    let
      parts = splitString ":" bdf;
      domain = elemAt parts 0;
      bus = elemAt parts 1;
      slotFunc = elemAt parts 2;
      sfParts = splitString "." slotFunc;
      slot = elemAt sfParts 0;
      func = elemAt sfParts 1;
    in
    "<address domain='0x${domain}' bus='0x${bus}' slot='0x${slot}' function='0x${func}'/>";

  # Generate the target dev name for a disk (vda, sdb, hdc, ...).
  indexToLetter = i: substring i 1 "abcdefghijklmnopqrstuvwxyz";
  diskDev =
    bus: index:
    let
      prefix =
        {
          virtio = "vd";
          sata = "sd";
          ide = "hd";
          scsi = "sd";
        }
        .${bus};
    in
    "${prefix}${indexToLetter index}";

  # ───────── XML generation ─────────

  generateXML =
    name: guest:
    let
      sdir = storageDir name guest;

      # OS / firmware
      osXML =
        if guest.firmware == "uefi" then
          if guest.secureBoot then
            ''
              <os firmware='efi'>
                <type arch='${guest.architecture}' machine='${guest.machineType}'>hvm</type>
                <feature name='secure-boot'/>
                <boot dev='${guest.bootDevice}'/>
              </os>''
          else
            ''
              <os firmware='efi'>
                <type arch='${guest.architecture}' machine='${guest.machineType}'>hvm</type>
                <boot dev='${guest.bootDevice}'/>
              </os>''
        else
          ''
            <os>
              <type arch='${guest.architecture}' machine='${guest.machineType}'>hvm</type>
              <boot dev='${guest.bootDevice}'/>
            </os>'';

      # Features
      featuresXML = ''
        <features>
          <acpi/>
          <apic/>
          ${optionalString guest.secureBoot "<smm state='on'/>"}
        </features>'';

      # CPU
      cpuXML = "<cpu mode='${guest.cpuMode}' check='none'/>";

      # Hard disks
      diskEntries = imap0 (i: disk: ''
        <disk type='file' device='disk'>
          <driver name='qemu' type='${disk.format}'/>
          <source file='${resolveDiskPath sdir disk}'/>
          <target dev='${diskDev disk.bus i}' bus='${disk.bus}'/>
          ${optionalString disk.readOnly "<readonly/>"}
        </disk>'') guest.disks;

      # CD-ROM for install ISO (uses sata bus, picks letter after hard disks)
      # Supports both local paths (installISO) and downloaded ISOs (installISOUrl).
      cdromSource =
        if guest.installISO != null then
          guest.installISO
        else if guest.installISOUrl != null then
          "${sdir}/${builtins.baseNameOf guest.installISOUrl}"
        else
          null;
      hasInstallCdrom = cdromSource != null;
      cdromEntry = optionalString hasInstallCdrom ''
        <disk type='file' device='cdrom'>
          <driver name='qemu' type='raw'/>
          <source file='${cdromSource}'/>
          <target dev='${diskDev "sata" (length guest.disks)}' bus='sata'/>
          <readonly/>
        </disk>'';

      # Cloud-init seed ISO CD-ROM (generated at runtime in preStart)
      seedISOEntry = optionalString guest.cloudInit.enable ''
        <disk type='file' device='cdrom'>
          <driver name='qemu' type='raw'/>
          <source file='${sdir}/cloud-init-seed.iso'/>
          <target dev='${
            diskDev "sata" (length guest.disks + (if hasInstallCdrom then 1 else 0))
          }' bus='sata'/>
          <readonly/>
        </disk>'';

      # Network interfaces
      ifaceEntries = imap0 (i: net: ''
        <interface type='${net.type}'>
          ${optionalString (net.type == "bridge") "<source bridge='${net.source}'/>"}
          ${optionalString (net.type == "network") "<source network='${net.source}'/>"}
          ${optionalString (net.type == "direct") "<source dev='${net.source}' mode='bridge'/>"}
          ${optionalString (net.mac != null) "<mac address='${net.mac}'/>"}
          <model type='${net.model}'/>
        </interface>'') guest.networks;

      # PCI passthrough
      pciEntries = map (dev: ''
        <hostdev mode='subsystem' type='pci' managed='yes'>
          <driver name='vfio-pci'/>
          <source>
            ${pciBdfToXml dev.id}
          </source>
          ${optionalString (!dev.romBar) "<rom bar='off'/>"}
        </hostdev>'') guest.passthrough.pci;

      # USB passthrough
      usbEntries = map (dev: ''
        <hostdev mode='subsystem' type='usb' managed='yes'>
          <source>
            <vendor id='0x${dev.vendor}'/>
            <product id='0x${dev.product}'/>
          </source>
        </hostdev>'') guest.passthrough.usb;

      # TPM
      tpmEntry = optionalString guest.tpm.enable ''
        <tpm model='${guest.tpm.model}'>
          <backend type='emulator' version='${guest.tpm.version}'/>
        </tpm>'';

      # Graphics
      listenAddr = if guest.graphics.listen != null then guest.graphics.listen else "127.0.0.1";
      portAttr =
        if guest.graphics.port != null then "port='${toString guest.graphics.port}'" else "autoport='yes'";
      graphicsEntry =
        if guest.graphics.type == "none" then
          ""
        else
          ''
            <graphics type='${guest.graphics.type}' ${portAttr} listen='${listenAddr}'>
              <listen type='address' address='${listenAddr}'/>
            </graphics>'';

      # Input devices
      inputEntries =
        (optional guest.input.tablet "<input type='tablet' bus='usb'/>")
        ++ (optional guest.input.keyboard "<input type='keyboard' bus='ps2'/>")
        ++ (optional guest.input.mouse "<input type='mouse' bus='ps2'/>");

      # Video
      videoEntry =
        if guest.graphics.type == "none" && guest.video.model == "qxl" then
          "<video><model type='none'/></video>"
        else
          "<video><model type='${guest.video.model}' heads='${toString guest.video.heads}'/></video>";

      # Extra QEMU args
      qemuCmdline = optionalString (guest.extraQemuArgs != [ ]) ''
        <qemu:commandline>
          ${concatMapStrings (a: "<qemu:arg value='${a}'/>") guest.extraQemuArgs}
        </qemu:commandline>'';

      # Domain type attribute — use qemu namespace if we have extra args
      domainAttrs = optionalString (
        guest.extraQemuArgs != [ ]
      ) " xmlns:qemu='http://libvirt.org/schemas/domain/qemu/1.0'";
    in
    ''
      <domain type='kvm'${domainAttrs}>
        <name>${name}</name>
        <memory unit='MiB'>${toString guest.memory}</memory>
        <vcpu>${toString guest.vcpus}</vcpu>
        ${osXML}
        ${featuresXML}
        ${cpuXML}
        <devices>
          ${concatStrings diskEntries}
          ${cdromEntry}
          ${seedISOEntry}
          ${concatStrings ifaceEntries}
          ${concatStrings pciEntries}
          ${concatStrings usbEntries}
          ${tpmEntry}
          ${graphicsEntry}
          ${concatStringsSep "\n          " inputEntries}
          ${videoEntry}
        </devices>
        ${optionalString (guest.extraXML != null) guest.extraXML}
        ${qemuCmdline}
      </domain>'';

  # ───────── Systemd service generation ─────────

  mkGuestService =
    name: guest:
    let
      xml = generateXML name guest;
      xmlFile = pkgs.writeText "kvm-guest-${name}.xml" xml;
      sdir = storageDir name guest;

      virsh = "${config.virtualisation.libvirtd.package}/bin/virsh";
      qemuImg = "${config.virtualisation.libvirtd.qemu.package}/bin/qemu-img";

      # Create disk images if they don't exist.
      # Downloads from sourceUrl if set, otherwise creates an empty disk.
      diskCreation = concatMapStrings (
        disk:
        let
          p = resolveDiskPath sdir disk;
        in
        if disk.sourceUrl != null then
          ''
            path="${p}"
            if [ ! -e "$path" ]; then
              echo "Downloading disk image: ${disk.sourceUrl}"
              ${pkgs.curl}/bin/curl -LfS -o "$path" "${disk.sourceUrl}"
              ${optionalString (disk.size != null) ''
                echo "Resizing disk image to ${disk.size}"
                              ${qemuImg} resize "$path" ${disk.size}''}
            fi
          ''
        else
          ''
            path="${p}"
            if [ ! -e "$path" ]; then
              echo "Creating disk image: $path (${disk.size})"
              ${qemuImg} create -f ${disk.format} "$path" ${disk.size}
            fi
          ''
      ) guest.disks;

      # Download install ISO from URL if set (local paths need no download).
      isoDownload = optionalString (guest.installISOUrl != null) ''
        isoPath="${sdir}/${builtins.baseNameOf guest.installISOUrl}"
        if [ ! -e "$isoPath" ]; then
          echo "Downloading install ISO: ${guest.installISOUrl}"
          ${pkgs.curl}/bin/curl -LfS -o "$isoPath" "${guest.installISOUrl}"
        fi
      '';

      # Generate cloud-init seed ISO (at runtime, to inject decrypted password).
      ci = guest.cloudInit;
      cloudInitPasswordSecret = "kvm-guest-${name}-cloudinit-password";
      cloudInitPasswordPath = optionalString (
        ci.passwordAgePath != null
      ) config.age.secrets.${cloudInitPasswordSecret}.path;
      # Build user-data YAML (password section added at runtime if needed).
      userDataYaml = concatStringsSep "\n" (
        [
          "#cloud-config"
          "hostname: ${ci.hostname}"
        ]
        ++ [
          "users:"
          "  - name: ${ci.user}"
          "    sudo: ALL=(ALL) NOPASSWD:ALL"
          "    groups: sudo"
          "    shell: /bin/bash"
        ]
        ++ [
          "    lock_passwd: ${
                if ci.passwordAgePath == null && ci.sshAuthorizedKeys != [ ] then "true" else "false"
              }"
        ]
        ++ (
          if ci.sshAuthorizedKeys != [ ] then
            [ "    ssh_authorized_keys:" ] ++ (map (k: "      - ${k}") ci.sshAuthorizedKeys)
          else
            [ ]
        )
        ++ (if ci.packages != [ ] then [ "packages:" ] ++ (map (p: "  - ${p}") ci.packages) else [ ])
        ++ (if ci.runcmd != [ ] then [ "runcmd:" ] ++ (map (c: "  - ${c}") ci.runcmd) else [ ])
        ++ (if ci.extraConfig != "" then [ ci.extraConfig ] else [ ])
        ++ (
          if ci.passwordAgePath == null && ci.sshAuthorizedKeys == [ ] then
            # No password and no SSH keys — default to username as password.
            [
              ""
              "chpasswd:"
              "  list: |"
              "    ${ci.user}:${ci.user}"
              "  expire: false"
            ]
          else
            [ ]
        )
      );
      seedISOCreation = optionalString ci.enable ''
        seedDir=$(mktemp -d)
        cat > "$seedDir/user-data" <<'CLOUDCFG'
        ${userDataYaml}
        CLOUDCFG
        ${optionalString (ci.passwordAgePath != null) ''
          echo "" >> "$seedDir/user-data"
          echo "chpasswd:" >> "$seedDir/user-data"
          echo "  list: |" >> "$seedDir/user-data"
          echo "    ${ci.user}:$(cat ${cloudInitPasswordPath})" >> "$seedDir/user-data"
          echo "  expire: false" >> "$seedDir/user-data"
        ''}
        cat > "$seedDir/meta-data" <<'METADATA'
        instance-id: ${name}
        local-hostname: ${ci.hostname}
        METADATA
        ${pkgs.cdrtools}/bin/mkisofs -quiet -output "${sdir}/cloud-init-seed.iso" \
          -volid cidata -joliet -rock "$seedDir/"
        rm -rf "$seedDir"
      '';

      # Graphics password setup via agenix (if configured).
      passwordSecret = "kvm-guest-${name}-graphics-password";
      graphicsPasswordSetup = optionalString (guest.graphics.passwordAgePath != null) ''
        # Set graphics password from decrypted age secret
        ${virsh} qemu-monitor-command ${name} -- \
          "{\"execute\": \"set_password\", \"arguments\": {\"protocol\": \"${guest.graphics.type}\", \"password\": \"$(cat ${
            config.age.secrets.${passwordSecret}.path
          })\"}}" \
          2>/dev/null || true
      '';
    in
    {
      description = "KVM guest: ${name}";

      wantedBy = optional guest.autoStart "multi-user.target";

      after = [ "libvirtd.service" ] ++ map (g: "kvm-guest-${g}.service") guest.dependsOn;
      requires = [ "libvirtd.service" ] ++ map (g: "kvm-guest-${g}.service") guest.dependsOn;

      path = [
        config.virtualisation.libvirtd.package
        config.virtualisation.libvirtd.qemu.package
        pkgs.cdrtools
      ];

      preStart = ''
        # Ensure storage directory exists
        mkdir -p "${sdir}"

        # Download install ISO from URL if needed
        ${isoDownload}

        # Create disk images if missing (existing disks are never recreated)
        ${diskCreation}

        # Generate cloud-init seed ISO if enabled
        ${seedISOCreation}

        # Define (or redefine) the domain with libvirt
        ${virsh} define --file "${xmlFile}"
      '';

      script = ''
        ${virsh} start ${name}
      '';

      postStart = graphicsPasswordSetup;

      preStop = ''
        ${virsh} shutdown ${name} || \
        ${virsh} destroy ${name} || true
      '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        TimeoutStopSec = 120;
      };
    };
in
{
  config = mkIf (cfg.guests != { }) {
    # ───────── Per-guest systemd services ─────────
    systemd.services = mapAttrs' (n: g: nameValuePair "kvm-guest-${n}" (mkGuestService n g)) (
      filterAttrs (_: g: g.enable) cfg.guests
    );

    # ───────── Secrets via agenix (graphics + cloud-init passwords) ─────────
    age.secrets = mkMerge (
      mapAttrsToList (
        name: guest:
        (optionalAttrs (guest.graphics.passwordAgePath != null) {
          "kvm-guest-${name}-graphics-password" = {
            file = guest.graphics.passwordAgePath;
          };
        })
        // (optionalAttrs (guest.cloudInit.enable && guest.cloudInit.passwordAgePath != null) {
          "kvm-guest-${name}-cloudinit-password" = {
            file = guest.cloudInit.passwordAgePath;
          };
        })
      ) (filterAttrs (_: g: g.enable) cfg.guests)
    );

    # ───────── Assertions ─────────
    assertions =
      let
        # Duplicate PCI passthrough across guests
        allPciIds = concatLists (
          mapAttrsToList (_: g: map (d: d.id) g.passthrough.pci) (filterAttrs (_: g: g.enable) cfg.guests)
        );
      in
      [
        {
          assertion = unique allPciIds == allPciIds;
          message = ''
            PCI device passthrough conflict: a PCI device is assigned to multiple
            guests. Check all guests' passthrough.pci entries for duplicates.
          '';
        }
      ]
      ++
        # Per-guest assertions
        flatten (
          mapAttrsToList (
            name: g:
            if !g.enable then
              [ ]
            else
              [
                {
                  assertion = !(g.secureBoot && g.firmware != "uefi");
                  message = "Guest ${name}: secureBoot requires firmware = \"uefi\".";
                }
                {
                  assertion = !(g.secureBoot && !g.tpm.enable);
                  message = "Guest ${name}: secureBoot requires tpm.enable = true.";
                }
                {
                  assertion = !(g.graphics.type == "none" && g.graphics.passwordAgePath != null);
                  message = "Guest ${name}: graphics.passwordAgePath requires graphics.type != \"none\".";
                }
                {
                  assertion = !(g.installISO != null && g.installISOUrl != null);
                  message = "Guest ${name}: installISO and installISOUrl are mutually exclusive.";
                }
              ]
          ) cfg.guests
        );
  };
}
