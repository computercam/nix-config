{ config, lib, pkgs, options, ... }:
let
  dockernet = "cybercrescendo";
in {
  config = {
    # cfg.docker.storage_root = "/Volumes/Server/docker/docker_storage_root";
    # cfg.docker.networking.iptables = "true";
    
    systemd.services.cybercrescendo_dockernet-create = {
      description = "Create the network bridge dockernet container to container networking.";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig.Type = "oneshot";
      script =
        let dockercli = "${config.virtualisation.docker.package}/bin/docker";
        in ''
          # Put a true at the end to prevent getting non-zero return code, which will
          # crash the whole service.

          check=$(${dockercli} network ls | grep "${dockernet}" || true)
          
          if [ -z "$check" ]; then
            ${dockercli} network create ${dockernet}
          else
            echo "${dockernet} already exists in docker"
          fi
        '';
    };
  };
}
