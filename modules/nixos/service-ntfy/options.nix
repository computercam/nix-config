{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.cfg.ntfy = {
    enable = mkEnableOption "ntfy push notification server";

    domain = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Public domain for the ntfy server (e.g. ntfy.example.com).
        When set, adds a cloudflared ingress entry — requires the
        service-cloudflared module to be imported on this host.
        Leave null for local-only access (no auth required).
      '';
    };

    port = mkOption {
      type = types.int;
      default = 2586;
      description = "Port for the ntfy HTTP server to listen on (localhost only).";
    };

    username = mkOption {
      type = types.str;
      default = "admin";
      description = "Admin username for ntfy authentication.";
    };

    passwordAgePath = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Path to the age-encrypted file containing the ntfy admin password.
        When set, enables authentication (auth-default-access: deny-all),
        requires login for the web UI, and creates the admin user on first run.
        Required when domain is set (public mode).
        Leave null for local-only access without authentication.
      '';
    };

    authDefaultAccess = mkOption {
      type = types.enum [ "read-write" "read-only" "write-only" "deny-all" ];
      default = "deny-all";
      description = ''
        Default access level for unauthenticated/unrecognized users when auth is enabled.
        The admin user always gets full access regardless of this setting.
        - "deny-all": no access without authentication (most secure)
        - "read-only": can subscribe but not publish
        - "read-write": can subscribe and publish
      '';
    };
  };
}
