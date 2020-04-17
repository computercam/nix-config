{ config, lib, pkgs, options, ... }:

with lib; {
  config = {
    virtualisation.docker.enable = true;
    docker-containers = {
      portainer = {
        image = "portainer/portainer";
        ports = [ "8000:8000" "9000:9000" ];
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
          "portainer_data:/data"
        ];
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "UTC";
        };
      };

      webserver = {
        image = "linuxserver/letsencrypt";
        ports = [ "80:80" "443:443" ];
        volumes = [ "letsencrypt_config:/config" ];
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "UTC";
          URL = "user.computer";
          SUBDOMAINS = "wildcard";
          VALIDATION = "dns";
          DNSPLUGIN = "cloudflare";
          EMAIL = "user@example.com";
        };
      };
    };
  };
}
