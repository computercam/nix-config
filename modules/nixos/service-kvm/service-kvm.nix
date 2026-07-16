{
  config,
  lib,
  pkgs,
  options,
  ...
}:
with lib;
let
  cfg = config.cfg.kvm;

  # ───────── CPU vendor detection ─────────
  # Derives from boot.kernelModules (declared in hardware-configuration.nix)
  # with /proc/cpuinfo probing as a last-resort fallback.
  cpuVendor =
    let
      v = cfg.host.cpuVendor;
    in
    if v != "auto" then
      v
    else if builtins.elem "kvm-intel" config.boot.kernelModules then
      "intel"
    else if builtins.elem "kvm-amd" config.boot.kernelModules then
      "amd"
    else
      builtins.readFile (
        pkgs.runCommand "cpu-vendor.txt" { } ''
          ((cat /proc/cpuinfo | grep vendor | head -n 1 | grep -i intel > /dev/null 2>&1) \
            && echo -n 'intel' || echo -n 'amd') > $out
        ''
      );

  # ───────── IOMMU auto-detection ─────────
  # Active when the user forces it OR any guest requests PCI passthrough.
  anyGuestPciPassthrough = lib.any (g: (g.passthrough.pci or [ ]) != [ ]) (
    builtins.attrValues cfg.guests
  );

  iommuActive = cfg.host.kernel.iommu.enable || anyGuestPciPassthrough;

  # ───────── Bundled hook scripts ─────────
  gpuPassthroughHook = pkgs.writeShellScript "gpu-passthrough" (
    builtins.readFile ./libvirt_hooks/gpu-passthrough.sh
  );

  libvirtNosleepHook = pkgs.writeShellScript "libvirt-nosleep" (
    builtins.readFile ./libvirt_hooks/libvirt-nosleep.sh
  );

  bundledHookMap = {
    "gpu-passthrough" = gpuPassthroughHook;
    "libvirt-nosleep" = libvirtNosleepHook;
  };

  # Generate the bundled hooks attrset from the user's selection.
  bundledHooks = lib.genAttrs cfg.host.libvirtd.hooks.bundled (name: bundledHookMap.${name});
in
{
  imports = [
    ../service-networking/service-networking.nix
    ./options.nix
    ./guests.nix
  ];

  config = mkMerge [
    {
      # ───────── Kernel / KVM modules ─────────
      boot.kernelModules = cfg.host.kernel.extraModules ++ optional iommuActive "vfio-pci";
      boot.kernelParams =
        cfg.host.kernel.extraParams
        ++ optionals iommuActive [
          "iommu=${cfg.host.kernel.iommu.mode}"
          "${cpuVendor}_iommu=on"
        ];
      boot.extraModprobeConfig = ''
        options kvm_${cpuVendor} nested=${if cfg.host.kernel.nested then "1" else "0"}
        options kvm ignore_msrs=${if cfg.host.kernel.ignoreMsrs then "1" else "0"}
      '';

      # ───────── libvirtd daemon ─────────
      virtualisation.libvirtd = {
        enable = true;
        onBoot = cfg.host.libvirtd.onBoot;
        onShutdown = cfg.host.libvirtd.onShutdown;
        parallelShutdown = cfg.host.libvirtd.parallelShutdown;
        shutdownTimeout = cfg.host.libvirtd.shutdownTimeout;
        startDelay = cfg.host.libvirtd.startDelay;
        allowedBridges = cfg.host.libvirtd.allowedBridges;
        extraConfig = cfg.host.libvirtd.extraConfig;
        extraOptions = cfg.host.libvirtd.extraOptions;
        firewallBackend = cfg.host.libvirtd.firewallBackend;
        qemu = {
          runAsRoot = cfg.host.libvirtd.runAsRoot;
          swtpm.enable = cfg.host.libvirtd.swtpm;
        };
        hooks.qemu = bundledHooks // cfg.host.libvirtd.hooks.qemu;
      };

      # ───────── Packages / tools ─────────
      environment.systemPackages =
        optionals cfg.host.tools.enable (
          with pkgs;
          [
            qemu
            libguestfs
            pciutils
            python3
            iproute2
          ]
        )
        ++ optionals (cfg.host.tools.enable && cfg.host.tools.gui) (
          with pkgs;
          [
            virt-manager
            virt-viewer
            dconf
          ]
        )
        ++ cfg.host.tools.extraPackages;

      # Default libvirt URI — so virsh, virt-manager, and virt-viewer
      # connect to qemu:///system (where guests are defined) by default,
      # instead of qemu:///session (per-user, empty by default).
      environment.variables.LIBVIRT_DEFAULT_URI = "qemu:///system";

      # Libvirt looks for hooks in /etc/libvirt/hooks/ but the NixOS module
      # places them in /var/lib/libvirt/hooks/. Symlink so libvirt finds them.
      environment.etc."libvirt/hooks".source = "/var/lib/libvirt/hooks";

      # ───────── User / permissions ─────────
      # Manage-scope users -> libvirtd (full access); monitor-scope users ->
      # kvm-monitors (read-only, enforced via the polkit rule below). No users
      # are added by default; list them explicitly under
      # cfg.kvm.host.libvirtd.users.{manage,monitor}.
      users.groups.kvm-monitors = { };
      users.users = mkMerge [
        (genAttrs cfg.host.libvirtd.users.manage (u: {
          extraGroups = [ "libvirtd" ];
        }))
        (genAttrs cfg.host.libvirtd.users.monitor (u: {
          extraGroups = [ "kvm-monitors" ];
        }))
      ];

      # Read-only monitor tier (polkit). Users in kvm-monitors get read-only
      # access to qemu:///system: unix.monitor is allowed, unix.manage is
      # denied. Enforced at the libvirt connection level (unlike per-op
      # api.* actions, which libvirt does not check on NixOS). Numbered 11
      # so it runs AFTER NixOS's 10-nixos.rules (which grants unix.manage to
      # the libvirtd group) -- first-match-wins means manage-scope users
      # keep full access even if also in kvm-monitors.
      environment.etc."polkit-1/rules.d/11-kvm-monitors.rules".text = ''
        polkit.addRule(function(action, subject) {
            if (subject.isInGroup("kvm-monitors")) {
                if (action.id == "org.libvirt.unix.monitor") {
                    return polkit.Result.YES;
                }
                if (action.id == "org.libvirt.unix.manage") {
                    return polkit.Result.NO;
                }
            }
        });
      '';

      security.pam.loginLimits = [
        {
          domain = "libvirtd";
          type = "soft";
          item = "memlock";
          value = "unlimited";
        }
        {
          domain = "libvirtd";
          type = "hard";
          item = "memlock";
          value = "unlimited";
        }
      ];

      # ───────── XRDP for remote VM control ─────────
      services.xrdp.enable = cfg.host.xrdp.enable;
      systemd.services.pcscd.enable = mkIf cfg.host.xrdp.enable false;
      systemd.sockets.pcscd.enable = mkIf cfg.host.xrdp.enable false;

      # ───────── libvirtd service path (for hooks) ─────────
      systemd.services.libvirtd.path =
        let
          env = pkgs.buildEnv {
            name = "qemu-hook-env";
            paths = with pkgs; [
              bash
              libvirt
              kmod
              systemd
              ripgrep
              sd
            ];
          };
        in
        [ env ];

      # ───────── Host networking (bridges) ─────────
      networking.bridges = listToAttrs (
        map (
          b:
          nameValuePair b.name {
            interfaces = optional (b.interface != null) b.interface;
          }
        ) cfg.host.networking.bridges
      );

      networking.interfaces = listToAttrs (
        flatten (
          map (
            b:
            optional (b.address != null) (
              nameValuePair b.name {
                ipv4.addresses = [
                  {
                    address = b.address;
                    prefixLength = b.prefixLength;
                  }
                ];
              }
            )
          ) cfg.host.networking.bridges
        )
      );
    }

    # ───────── Persistent storage: bind mount + storage pool ─────────
    # When persistentPath is set, bind-mount ${persistentPath}/host to
    # /var/lib/libvirt and register ${persistentPath}/guests as a libvirt pool.
    (mkIf (cfg.host.storage.persistentPath != null) {
      # Create directories with correct permissions before the bind mount
      systemd.services.kvm-prepare-state-dir = {
        description = "Prepare libvirt state directory on persistent storage";
        wantedBy = [ "multi-user.target" ];
        before = [
          "libvirtd.service"
          "kvm-cleanup.service"
        ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          mkdir -p "${cfg.host.storage.persistentPath}/host"
          mkdir -p "${cfg.host.storage.persistentPath}/guests"
          chown root:root "${cfg.host.storage.persistentPath}/host"
          chmod 755 "${cfg.host.storage.persistentPath}/host"
        '';
      };

      # Bind mount the persistent state path to /var/lib/libvirt
      fileSystems."/var/lib/libvirt" = {
        device = "${cfg.host.storage.persistentPath}/host";
        fsType = "none";
        options = [ "bind" ];
      };

      # Register the guests directory as a libvirt storage pool
      systemd.services.kvm-host-setup = {
        description = "KVM host storage pool setup";
        after = [ "libvirtd.service" ];
        requires = [ "libvirtd.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        path = [ config.virtualisation.libvirtd.package ];
        script = ''
          # Only define the pool if it doesn't already exist
          if ! virsh pool-list --all --name 2>/dev/null | grep -qw kvm-guests; then
            virsh pool-define /dev/stdin <<'POOLXML'
          <pool type='dir'>
            <name>kvm-guests</name>
            <target>
              <path>${cfg.host.storage.persistentPath}/guests</path>
            </target>
          </pool>
          POOLXML
          fi
          virsh pool-start kvm-guests 2>/dev/null || true
          virsh pool-autostart kvm-guests 2>/dev/null || true
        '';
      };
    })

    # ───────── libvirt-nosleep template service ─────────
    (mkIf (elem "libvirt-nosleep" cfg.host.libvirtd.hooks.bundled) {
      systemd.services."libvirt-nosleep@" = {
        unitConfig.Description = ''Preventing sleep while libvirt domain "%i" is running'';
        serviceConfig = {
          Type = "simple";
          ExecStart = ''/run/current-system/sw/bin/systemd-inhibit --what=sleep --why="Libvirt domain \"%i\" is running" --who=%U --mode=block sleep infinity'';
        };
      };
    })

    # ───────── VFIO PCI device binding ─────────
    # When any guest requests PCI passthrough, bind the devices to vfio-pci at boot.
    (mkIf iommuActive {
      boot.extraModprobeConfig = mkAfter ''
        ${optionalString anyGuestPciPassthrough ''
          options vfio-pci ids=${
            concatStringsSep "," (
              unique (concatLists (mapAttrsToList (_: g: map (d: d.id) g.passthrough.pci) cfg.guests))
            )
          }
        ''}
      '';
    })
  ];
}
