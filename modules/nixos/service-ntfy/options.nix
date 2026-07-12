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
  };
}
