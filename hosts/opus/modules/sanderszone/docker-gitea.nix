{ config, lib, pkgs, options, ... }: 
let
  gitea_public_domain = "gitea.sanders.zone";
  gitea_web_port = 3000;
  gitea_ssh_port = 222;
in {
  config = {
    virtualisation.oci-containers.containers = {
      gitea = {
        image = "gitea/gitea:1.17.1";
        ports = [ 
          "${builtins.toString gitea_web_port}:3000"
          "${builtins.toString gitea_ssh_port}:22"
        ];
        volumes = [
          "/Volumes/Server/sanderszone/gitea:/data"
          "/etc/timezone:/etc/timezone:ro"
          "/etc/localtime:/etc/localtime:ro"
        ];
        environment = {
          USER_UID = "1000";
          USER_GID = "992";
        };
        extraOptions = [ 
          "--network=sanderszone"
        ];
      };
    };

    networking.firewall.allowedTCPPorts = [ 
      gitea_web_port 
      gitea_ssh_port 
    ];

    services.cloudflared = {
      tunnels."${config.networking.hostName}" = {
        ingress = {
          "${gitea_public_domain}" = "http://${config.cfg.networking.static.ip_address}:${builtins.toString gitea_web_port}";
        };
      };
    };
  };
}
