{
  config,
  lib,
  pkgs,
  ...
}:
with pkgs.stdenv;
with lib;
let
  cfg = config.cfg.monitoring;

  customStateDir = cfg.stateDir != "/var/lib/netdata";

  # Internal port for the nginx auth proxy (only used when auth is enabled).
  authProxyPort = 8098;

in
{
  imports = [ ./options.nix ];

  config = mkMerge [
    # ── Assertions ────────────────────────────────────────────────────────────
    {
      assertions = [
        {
          assertion = cfg.withDashboard -> pkgs.netdataCloud.meta.available or false;
          message = ''
            cfg.monitoring.withDashboard is true but the netdataCloud package is
            not available.  This package requires nixpkgs.config.allowUnfree = true
            (it ships the NCUL1-licensed web dashboard).
          '';
        }
        {
          assertion = !(cfg.domain != null && cfg.auth.enable) || config.services.nginx.enable;
          message = "services.nginx.enable must be true when cfg.monitoring.auth is enabled (nginx provides the basic auth proxy)";
        }
        {
          assertion = !(cfg.domain != null && cfg.auth.enable) || cfg.auth.passwordAgePath != null;
          message = "cfg.monitoring.auth.passwordAgePath must be set when auth is enabled";
        }
        {
          assertion = !cfg.notifications.enable || config.cfg.ntfy.enable or false;
          message = "cfg.ntfy.enable must be true when cfg.monitoring.notifications is enabled (requires the service-ntfy module)";
        }
      ];
    }

    # ── Core Netdata ────────────────────────────────────────────────────────
    {
      services.netdata = {
        enable = true;
        package = mkDefault (if cfg.withDashboard then pkgs.netdataCloud else pkgs.netdata);
        enableAnalyticsReporting = cfg.analytics;
        python.enable = cfg.python.enable;
        python.recommendedPythonPackages = cfg.python.recommendedPackages;
        config = {
          db = {
            mode = "dbengine";
          };
          web = {
            "bind to" = "${cfg.bindAddress}:${toString cfg.port}";
          };
        };
      };
    }

    # ── Streaming disabled: static stream.conf ──────────────────────────────
    # Always generate stream.conf at runtime so the API key never lands in
    # the Nix store.  Even the "disabled" config is written via ExecStartPre
    # so that switching between enabled/disabled always overwrites the file.
    (mkIf (!cfg.streaming.enable) {
      systemd.services.netdata.serviceConfig.ExecStartPre =
        let
          script = pkgs.writeShellScript "netdata-stream-conf" ''
            rm -f /etc/netdata/stream.conf
            cat > /etc/netdata/stream.conf <<CONF
            [stream]
                enabled = no
            CONF
            chmod 600 /etc/netdata/stream.conf
            chown netdata:netdata /etc/netdata/stream.conf
          '';
        in [ "+${script}" ];
    })

    # ── Streaming enabled: assertions and age secret ─────────────────────────
    (mkIf cfg.streaming.enable {
      assertions = [
        {
          assertion = cfg.streaming.apiKeyAgePath != null;
          message = "cfg.monitoring.streaming.apiKeyAgePath must be set when streaming is enabled";
        }
      ];

      age.secrets.netdata_streaming_api_key.file = cfg.streaming.apiKeyAgePath;
    })

    # ── Streaming enabled: parent role ──────────────────────────────────────
    # stream.conf is an INI file, so the API key must be written to disk as
    # the section header.  Inline $(cat ...) avoids an intermediate shell
    # variable.  File is chmod 600, owned by netdata:netdata.
    (mkIf (cfg.streaming.enable && cfg.streaming.role == "parent") {
      systemd.services.netdata.serviceConfig.ExecStartPre =
        let
          apiKeyPath = config.age.secrets.netdata_streaming_api_key.path;
          script = pkgs.writeShellScript "netdata-stream-conf" ''
            rm -f /etc/netdata/stream.conf
            cat > /etc/netdata/stream.conf <<CONF
            [$(cat ${apiKeyPath})]
                enabled = yes
                # Accept streaming from any IP — Netdata is intended to be accessed
                # from the LAN or via a Cloudflare tunnel. The firewall restricts
                # which IPs can reach the port.
                allow from = *
                default history = 3600
                health enabled by default = auto
                default proxy enabled = no
            CONF
            chmod 600 /etc/netdata/stream.conf
            chown netdata:netdata /etc/netdata/stream.conf
          '';
        in [ "+${script}" ];
    })

    # ── Streaming enabled: child role ───────────────────────────────────────
    # stream.conf is an INI file, so the API key must be written to disk as
    # a key-value pair.  Inline $(cat ...) avoids an intermediate shell
    # variable.  File is chmod 600, owned by netdata:netdata.
    (mkIf (cfg.streaming.enable && cfg.streaming.role == "child") {
      systemd.services.netdata.serviceConfig.ExecStartPre =
        let
          apiKeyPath = config.age.secrets.netdata_streaming_api_key.path;
          script = pkgs.writeShellScript "netdata-stream-conf" ''
            rm -f /etc/netdata/stream.conf
            cat > /etc/netdata/stream.conf <<CONF
            [stream]
                enabled = yes
                destination = ${cfg.streaming.parentAddress}:${toString cfg.streaming.parentPort}
                api key = $(cat ${apiKeyPath})
                timeout seconds = 60
                default port = 19999
                send charts every = 120
                buffer flush seconds = 5
            CONF
            chmod 600 /etc/netdata/stream.conf
            chown netdata:netdata /etc/netdata/stream.conf
          '';
        in [ "+${script}" ];
    })

    # ── Custom State Directory ──────────────────────────────────────────────
    # By default, Netdata stores its dbengine data and SQLite metadata in
    # /var/cache/netdata (managed by systemd's CacheDirectory).  Setting
    # cfg.monitoring.stateDir to a path on persistent storage (e.g.
    # /Volumes/Server/netdata) keeps metrics across reimaging.
    #
    # The [directories].cache option controls the base directory that Netdata
    # uses for dbengine tier paths ({cache}/dbengine, {cache}/dbengine-tier1,
    # etc.) and SQLite metadata databases.
    (mkIf customStateDir {
      systemd.tmpfiles.settings."10-netdata-monitoring" = {
        "${cfg.stateDir}" = {
          d = {
            mode = "0750";
            user = "netdata";
            group = "netdata";
          };
        };
      };

      services.netdata.config.directories.cache = cfg.stateDir;
    })

    # ── Firewall ────────────────────────────────────────────────────────────
    (mkIf cfg.openFirewall {
      networking.firewall.allowedTCPPorts = [ cfg.port ];
    })

    # ── Cloudflared ingress (no auth) ────────────────────────────────────────
    # Direct to Netdata when auth is disabled.
    (mkIf (cfg.domain != null && !cfg.auth.enable) {
      services.cloudflared = {
        tunnels."${config.networking.hostName}".ingress."${cfg.domain}" =
          "http://127.0.0.1:${toString cfg.port}";
      };
    })

    # ── Cloudflared ingress (with auth) ──────────────────────────────────────
    # Routes through an nginx reverse proxy with basic auth.
    # Cloudflared → nginx (auth) → Netdata.
    # LAN access to Netdata is unaffected (still direct, no auth).
    (mkIf (cfg.domain != null && cfg.auth.enable) {
      age.secrets.netdata_auth_password = {
        file = cfg.auth.passwordAgePath;
      };

      # Generate the htpasswd file from the age secret at boot.
      # Stored on tmpfs (/run/) so it disappears on reboot.
      systemd.services.netdata-auth-htpasswd = {
        description = "Generate Netdata basic auth htpasswd file";
        wantedBy = [ "multi-user.target" ];
        before = [ "nginx.service" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          PASSWORD="$(cat ${config.age.secrets.netdata_auth_password.path})"
          HASH="$(${pkgs.openssl}/bin/openssl passwd -apr1 "$PASSWORD")"
          echo "${cfg.auth.username}:$HASH" > /run/netdata-auth.htpasswd
          chown nginx:nginx /run/netdata-auth.htpasswd
          chmod 400 /run/netdata-auth.htpasswd
        '';
      };

      # nginx reverse proxy with basic auth in front of Netdata.
      services.nginx.virtualHosts."${cfg.domain}" = {
        listen = [ { addr = "127.0.0.1"; port = authProxyPort; } ];
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          extraConfig = ''
            auth_basic "Restricted";
            auth_basic_user_file /run/netdata-auth.htpasswd;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
          '';
        };
      };

      # Cloudflared routes to nginx (auth proxy) instead of Netdata directly.
      services.cloudflared = {
        tunnels."${config.networking.hostName}".ingress."${cfg.domain}" =
          "http://127.0.0.1:${toString authProxyPort}";
      };
    })

    # ── Optional: Prometheus Node Exporter ───────────────────────────────────
    (mkIf cfg.exporters.node {
      services.prometheus.exporters.node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
      };
    })

    # ── Optional: Prometheus Smartctl Exporter ──────────────────────────────
    (mkIf cfg.exporters.smartctl {
      services.prometheus.exporters.smartctl.enable = true;
    })

    # ── Notifications via ntfy ──────────────────────────────────────────────
    # Writes health_alarm_notify.conf at runtime.  The ntfy URL, username,
    # and password source are derived from cfg.ntfy — no duplicate options.
    # The password is NOT written to disk: the conf file contains a shell
    # command that reads it from the agenix tmpfs file when Netdata sources
    # the conf.  A separate age secret (owned by netdata) is declared so
    # the netdata user can read the password at runtime.
    (mkIf cfg.notifications.enable {
      # Declare a netdata-owned copy of the ntfy password secret so
      # alarm-notify.sh can read it when sourcing the conf file.
      age.secrets.netdata_ntfy_password = {
        file = config.cfg.ntfy.passwordAgePath;
        owner = "netdata";
        group = "netdata";
      };

      systemd.services.netdata.serviceConfig.ExecStartPre =
        let
          passwordPath = config.age.secrets.netdata_ntfy_password.path;
          script = pkgs.writeShellScript "netdata-health-notify-conf" ''
            rm -f /etc/netdata/health_alarm_notify.conf
            cat > /etc/netdata/health_alarm_notify.conf <<CONF
            SEND_NTFY="YES"
            NTFY_URL="https://${config.cfg.ntfy.domain}"
            DEFAULT_RECIPIENT_NTFY="${cfg.notifications.topic}"
            NTFY_USERNAME="${config.cfg.ntfy.username}"
            NTFY_PASSWORD="\$(cat ${passwordPath})"
            CONF
            chmod 600 /etc/netdata/health_alarm_notify.conf
            chown netdata:netdata /etc/netdata/health_alarm_notify.conf
          '';
        in [ "+${script}" ];
    })
  ];
}
