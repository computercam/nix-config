{ config, lib, pkgs, options, ... }: 
let 
  nextcloud_home_dir = "/Volumes/Server/cybercrescendo/nextcloud";
  nextcloud_public_domain = "nextcloud.cybercrescendo.com";
  nextcloud_private_domain = "homeserver.local";
  nextcloud_local_port = 11000;
in {
  age.secrets = {
    nextcloud_admin_password.file = ../../../secrets/nextcloud_admin_password.age;
  };

  # Open the Nextcloud port.
  networking.firewall.allowedTCPPorts = [ nextcloud_local_port ];

  # Cloudflared config
  services.cloudflared = {
    tunnels."07c9f962-1f28-42ec-bc26-f997937bc678" = {
      ingress = {
        "${nextcloud_public_domain}" = "http://${config.cfg.networking.static.ip_address}:${builtins.toString nextcloud_local_port}";
      };
    };
  };

  virtualisation.oci-containers.containers = {
    nextcloud-aio-mastercontainer = {
      image = "nextcloud/all-in-one:latest";
      autoStart = true;
      ports = [
        "8080:8080"
      ];
      volumes = [
        "nextcloud_aio_mastercontainer:/mnt/docker-aio-config"
        "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];
      environment = {
        SKIP_DOMAIN_VALIDATION = "true";
        APACHE_PORT = "${toString nextcloud_local_port}";
        APACHE_IP_BINDING = "0.0.0.0";
        NEXTCLOUD_DATADIR = "${nextcloud_home_dir}/data";
        NEXTCLOUD_MEMORY_LIMIT = "4096M";
      };
      extraOptions = [
        "--network=cybercrescendo"
        "--init"
        "--sig-proxy=false"
      ];
    };
  };
}