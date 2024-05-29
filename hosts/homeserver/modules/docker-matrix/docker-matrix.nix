{ config, lib, pkgs, options, ... }:
let
  fgetHomeserverConfig = import ./getHomeserverConfig.nix;
  fgetLogConfig = import ./getLogConfig.nix;
  fgetElementConfig = import ./getElementConfig.nix;

  rootpath = "/Volumes/Server/docker/matrix";
  username = "matrix";
  guid = 9000;

  homeserverConfig = {
    domain = "matrix.cameron.computer";
    port = 8008;
    postgres = {
      user = "postgres";
      pass = "postgres";
      name = "postgres";
      host = "matrix-postgres";
    };
    enableRegistration = true;
  };

  homeserverConfigText = fgetHomeserverConfig { lib = lib; pkgs= pkgs; homeserverConfig = homeserverConfig; };
  logConfigText = fgetLogConfig { lib = lib; pkgs= pkgs; homeserverConfig = homeserverConfig; };
  elementConfig = fgetElementConfig { lib = lib; pkgs= pkgs; homeserverConfig = homeserverConfig; };

  # SECRET_KEY = "`cat ${config.age.secrets.glitchtip_key.path}`";
in {
  config = {
    users.groups."${username}" = {
      name = "${username}";
      gid = guid;
    };
    users.users."${username}" = {
      extraGroups = [ "${username}" ];
      name = "${username}";
      uid = guid;
      group = "${username}";
      isNormalUser = true;
      home = rootpath;
    };

    systemd.services.docker-matrix-synapse.preStart = ''
      DATA_DIR=${rootpath}/synapse
      HOMESERVER_CONFIG_PATH=$DATA_DIR/homeserver.yaml
      LOG_CONFIG_PATH=$DATA_DIR/${homeserverConfig.domain}.log.config 
      
      mkdir -p $DATA_DIR
      
      echo -e '${homeserverConfigText}' > $HOMESERVER_CONFIG_PATH
      echo -e '${logConfigText}' > $LOG_CONFIG_PATH

      chown -R ${username}:${username} ${rootpath}/synapse

      chmod 644 $HOMESERVER_CONFIG_PATH
      chmod 644 $LOG_CONFIG_PATH
    '';

    systemd.services.docker-matrix-element.preStart = ''
      DATA_DIR=${rootpath}/element
      CONFIG_PATH=$DATA_DIR/config.json

      echo -e '${elementConfig}' > $CONFIG_PATH

      chmod 644 $CONFIG_PATH
    '';

    virtualisation.oci-containers.containers = {
      matrix-synapse = {
        image = "matrixdotorg/synapse:v1.107.0";
        volumes =  [ 
          "${rootpath}/synapse:/data" 
        ];
        # ports = [ "8008:8008" ];
        dependsOn = [ homeserverConfig.postgres.host ];
        # environmentFiles = [ "${rootpath}.env.secret" ];
        environment = {
            UID = builtins.toString guid;
            GID = builtins.toString guid;
        };
        # autoStart = false;
        extraOptions =
          [ 
            "--network=${config.cfg.docker.networking.dockernet}"
          ];
      };

      matrix-element = {
        image = "vectorim/element-web:v1.11.67";
        volumes = [ "${rootpath}/element/config.json:/app/config.json" ];
        # ports = [ "8010:80" ];
        dependsOn = [ "matrix-synapse" ];
        # environmentFiles = [ "${rootpath}.env.secret" ];
        extraOptions =
          [ "--network=${config.cfg.docker.networking.dockernet}" ];
      };

      # TODO: use matrix-user (or matrix db user)
      # https://github.com/docker-library/docs/blob/master/postgres/README.md#arbitrary---user-notes
      "${homeserverConfig.postgres.host}" = {
        image = "postgres:15";
        volumes = [
          "${rootpath}/postgres:/var/lib/postgresql/data"
        ];
        environment = {
          POSTGRES_USER = homeserverConfig.postgres.user;
          # TODO: Put db password in env.secret file and don't pass here
          POSTGRES_PASSWORD = homeserverConfig.postgres.pass;
          POSTGRES_DB = homeserverConfig.postgres.name;
          POSTGRES_INITDB_ARGS = "--encoding=UTF-8 --lc-collate=C --lc-ctype=C";
        };
        # environmentFiles = [ "${rootpath}.env.secret" ];
        extraOptions =
          [ "--network=${config.cfg.docker.networking.dockernet}" ];
      };

    };
  };
}
