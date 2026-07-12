{
  config,
  lib,
  pkgs,
  ...
}:
with pkgs.stdenv;
with lib;
{
  options.cfg.monitoring = {
    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/netdata";
      description = ''
        Base directory for Netdata's cache data (dbengine tiers + SQLite
        Maps to the [directories].cache option in netdata.conf.
        Set to a persistent path (e.g. on /Volumes/Server) to survive
        reimaging — the default /var/lib/netdata is on the root filesystem.
      '';
    };

    bindAddress = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Address for the Netdata web dashboard to bind to. Use \"0.0.0.0\" to allow remote access.";
    };

    port = mkOption {
      type = types.int;
      default = 19999;
      description = "Port for the Netdata web dashboard.";
    };

    analytics = mkOption {
      type = types.bool;
      default = false;
      description = "Enable anonymous usage statistics reporting to Netdata Inc.";
    };

    withDashboard = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Include the Netdata web dashboard (the bundled React frontend).

        This uses the `netdataCloud` package which bundles the dashboard under
        the NCUL1 license.  NCUL1 permits free personal and internal business
        use but restricts redistribution and modification of the UI code.
        Set to `false` to use the headless `netdata` package (API-only, no UI).
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = config.cfg.monitoring.bindAddress != "127.0.0.1" && config.cfg.monitoring.bindAddress != "::1" && config.cfg.monitoring.bindAddress != "localhost";
      defaultText = literalExpression ''cfg.monitoring.bindAddress != "127.0.0.1" && cfg.monitoring.bindAddress != "::1" && cfg.monitoring.bindAddress != "localhost"'';
      description = ''
        Open the Netdata web port in the firewall.
        Defaults to `true` when bindAddress is not a loopback address.
      '';
    };

    domain = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Public domain for the Netdata dashboard (e.g. netdata.example.com).
        When set, adds a cloudflared ingress entry — requires the
        service-cloudflared module to be imported on this host.
        Leave null for local-only access (use bindAddress + openFirewall instead).
      '';
    };

    auth = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Require HTTP basic auth for public access via cloudflared.
          Creates an nginx reverse proxy with basic auth in front of Netdata.
          Requires services.nginx to be enabled on this host.
          LAN access to Netdata is unaffected (still auth-free).
        '';
      };

      username = mkOption {
        type = types.str;
        default = "admin";
        description = "Username for basic auth.";
      };

      passwordAgePath = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          Path to the age-encrypted file containing the basic auth password.
          Required when auth is enabled.
        '';
      };
    };

    python = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable Python-based Netdata collectors (Docker, PostgreSQL, etc.).";
      };

      recommendedPackages = mkOption {
        type = types.bool;
        default = true;
        description = "Install recommended Python packages for additional collectors (requests, pandas, psycopg2, etc.).";
      };
    };

    streaming = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Netdata streaming for parent/child topology. Children stream metrics to a parent for centralized viewing.";
      };

      role = mkOption {
        type = types.enum [ "parent" "child" ];
        default = "parent";
        description = "Streaming role: \"parent\" receives metrics from children, \"child\" sends metrics to a parent.";
      };

      parentAddress = mkOption {
        type = types.str;
        default = "";
        description = "Address of the parent Netdata node (used when role is \"child\").";
      };

      parentPort = mkOption {
        type = types.int;
        default = 19999;
        description = "Port of the parent Netdata streaming endpoint (used when role is \"child\").";
      };

      apiKeyAgePath = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Path to the age-encrypted file containing the shared API key for Netdata streaming. Generate a key with: uuidgen";
      };
    };

    exporters = {
      node = mkOption {
        type = types.bool;
        default = false;
        description = "Run Prometheus node_exporter alongside Netdata. Useful if you also have an external Prometheus server.";
      };

      smartctl = mkOption {
        type = types.bool;
        default = false;
        description = "Run Prometheus smartctl_exporter for disk S.M.A.R.T. metrics alongside Netdata.";
      };
    };

    notifications = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable health alarm notifications via ntfy.
          Requires the service-ntfy module to be imported on this host.
          The ntfy URL, username, and password are derived from cfg.ntfy.
        '';
      };

      topic = mkOption {
        type = types.str;
        default = "netdata-alerts";
        description = "ntfy topic to publish alarm notifications to.";
      };
    };
  };
}
