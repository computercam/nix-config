{ config, lib, pkgs, options, ... }: {
  config = {
    virtualisation.oci-containers.containers = {
      resilio-sync = {
        image = "linuxserver/resilio-sync";
        ports = [ 
          "${config.cfg.networking.static.ip_address}:8888:8888" 
          "${config.cfg.networking.static.ip_address}:55555:55555" 
        ];
        volumes = [
          "/Volumes/Server/docker/resiliosync/config:/config"
          "/Volumes/Server/docker/resiliosync/downloads:/downloads"
          "/Volumes/Storage:/sync"
        ];
        environment = {
          PUID = "1000";
          PGID = "996";
          TZ = "America/Chicago";
        };
        extraOptions = [ 
          "--network=${config.cfg.docker.networking.dockernet}" 
          "--label=swag=enable" 
        ];
      };
    };

    # networking.firewall.allowedTCPPorts = [
    #   8888
    #   55555
    # ];
  };
}
