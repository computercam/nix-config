{ config, lib, pkgs, options, ... }: 
let
  tunnelconfig = ''
    ingress:
      - hostname: cybercrescendo.com
        service: https://cybercrescendo.com
      - hostname: '*.cybercrescendo.com'
        service: https://cybercrescendo.com
      - service: http_status:404
  '';
  swag_presetart = ''
    SWAG_DIR="/Volumes/Server/docker/cybercrescendo/swag"
    CONFIG_DIR="$SWAG_DIR/config"
    INI_DIR="$SWAG_DIR/config/dns-conf"
    INI_FILE="$INI_DIR/cloudflare.ini"
    ENV_FILE="$SWAG_DIR/.env.secret"
    
    mkdir -p $INI_DIR
    mkdir -p $CONFIG_DIR

    CF_ACCOUNT_ID=`cat ${config.age.secrets.cf_account_id.path}`
    CF_TUNNEL_PASSWORD=`cat ${config.age.secrets.cf_tunnel_password.path}`
    CF_ZONE_ID=`cat ${config.age.secrets.cf_zone_id.path}`
    CF_API_TOKEN=`cat ${config.age.secrets.cf_api_token.path}`

    echo "CF_ACCOUNT_ID=$CF_ACCOUNT_ID" > $ENV_FILE
    echo "CF_TUNNEL_PASSWORD=$CF_TUNNEL_PASSWORD" >> $ENV_FILE
    echo "CF_ZONE_ID=$CF_ZONE_ID" >> $ENV_FILE
    echo "CF_API_TOKEN=$CF_API_TOKEN" >> $ENV_FILE
    echo "dns_cloudflare_api_token = $CF_API_TOKEN" > $INI_FILE
    echo "${tunnelconfig}" > $CONFIG_DIR/tunnelconfig.yml

    chmod 600 $ENV_FILE
    chmod 600 $INI_FILE
    chown root:root $ENV_FILE
    chown root:root $INI_FILE
  '';
in {
  config = {
    age.secrets = {
      cf_account_id.file = ../../../secrets/cf_account_id.age;
      cf_api_token.file = ../../../secrets/cf_cc_api_token.age;
      cf_tunnel_password.file = ../../../secrets/cf_tunnel_password.age;
      cf_zone_id.file = ../../../secrets/cf_cc_zone_id.age;
    };

    systemd.services.docker-swag.preStart = swag_presetart;

    virtualisation.oci-containers.containers = {
      swag = {
        image = "lscr.io/linuxserver/swag";
        volumes = [ 
          "/Volumes/Server/docker/cybercrescendo/swag/config:/config"
        ];
        environment = {
          PUID = "1000";
          PGID = "996";
          TZ = "America/Chicago";
          URL = "cybercrescendo.com";
          SUBDOMAINS = "wildcard";
          VALIDATION = "dns";
          DNSPLUGIN = "cloudflare";
          EMAIL = "cameron@cybercrescendo.com";
          DOCKER_MODS= "linuxserver/mods:swag-auto-proxy|linuxserver/mods:universal-docker|linuxserver/mods:universal-cloudflared";
          DOCKER_HOST = "dockerproxy";
          CF_TUNNEL_NAME = "cybercrescendo.com";
          FILE__CF_TUNNEL_CONFIG = "/config/tunnelconfig.yml";
        };
        environmentFiles = [ /Volumes/Server/docker/cybercrescendo/swag/.env.secret ];
        extraOptions = [ 
          "--network=cybercrescendo"
          "--add-host=cybercrescendo.com:127.0.0.1"
          "--cap-add=NET_ADMIN"
        ];
      };

      dockerproxy = {
        image = "ghcr.io/tecnativa/docker-socket-proxy";
        volumes = [ "/var/run/docker.sock:/var/run/docker.sock:ro" ];
        environment = {
          CONTAINERS = "1";
          POST = "0"; 
        };
        extraOptions = [ "--network=cybercrescendo" ];
      };
    };

    # networking.firewall.allowedTCPPorts = [ 443 ];
  };
}
