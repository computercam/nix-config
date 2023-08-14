{ config, lib, pkgs, options, ... }:
with pkgs.stdenv;
with lib; {
  imports = [ ./options.nix ];

  config = {
    users.groups.docker = { };
    users.users."${config.cfg.user.name}".extraGroups = [ "docker" ];

    environment.systemPackages = with pkgs; [ docker-compose docker-client ];

    virtualisation.oci-containers.backend = "docker";

    virtualisation.docker = {
      enable = true;
      storageDriver = "overlay2";
      extraOptions = ''
        --bip="${config.cfg.docker.networking.bip}" --data-root="${config.cfg.docker.storage_root}" --dns="${config.cfg.docker.networking.dns.primary}" --dns="${config.cfg.docker.networking.dns.secondary}" --iptables=${config.cfg.docker.networking.iptables}'';
    };

    systemd.services.dockernet-create = {
      description = "Create the network bridge dockernet container to container networking.";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig.Type = "oneshot";
      script =
        let dockercli = "${config.virtualisation.docker.package}/bin/docker";
        in ''
          # Put a true at the end to prevent getting non-zero return code, which will
          # crash the whole service.

          check=$(${dockercli} network ls | grep "${config.cfg.docker.networking.dockernet}" || true)
          
          if [ -z "$check" ]; then
            ${dockercli} network create ${config.cfg.docker.networking.dockernet}
          else
            echo "${config.cfg.docker.networking.dockernet} already exists in docker"
          fi
        '';
    };
  };
}
