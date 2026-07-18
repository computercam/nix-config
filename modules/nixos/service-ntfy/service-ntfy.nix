{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.cfg.ntfy;
  authEnabled = cfg.passwordAgePath != null;
in
{
  imports = [ ./options.nix ];

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.domain == null || cfg.passwordAgePath != null;
        message = "cfg.ntfy.passwordAgePath must be set when domain is configured (public mode requires auth)";
      }
    ];

    age.secrets.ntfy_password = mkIf authEnabled {
      file = cfg.passwordAgePath;
    };

    services.ntfy-sh = {
      enable = true;
      settings = {
        listen-http = "127.0.0.1:${toString cfg.port}";
        auth-file = "/var/lib/ntfy-sh/user.db";
        auth-default-access = if authEnabled then cfg.authDefaultAccess else "read-write";
        behind-proxy = cfg.domain != null;
      } // (optionalAttrs (cfg.domain != null) {
        base-url = "https://${cfg.domain}";
      }) // (optionalAttrs authEnabled {
        enable-login = true;
        require-login = true;
      });
    };

    # Override DynamicUser so the init script can chown files to a fixed user.
    systemd.services.ntfy-sh.serviceConfig.DynamicUser = mkForce false;

    # Create the admin user after the server has started and created the
    # auth database.  ntfy reads the user database dynamically, so no
    # restart is needed after adding the user.  The brief window without
    # users is safe — the server is localhost-only with deny-all access.
    systemd.services.ntfy-sh-init = mkIf authEnabled {
      description = "Initialize ntfy-sh admin user";
      wantedBy = [ "multi-user.target" ];
      after = [ "ntfy-sh.service" ];
      requires = [ "ntfy-sh.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        # Wait for the server to create the auth database
        for i in $(seq 1 30); do
          if [ -f "/var/lib/ntfy-sh/user.db" ]; then
            break
          fi
          sleep 1
        done

        if [ ! -f "/var/lib/ntfy-sh/user.db" ]; then
          echo "ERROR: ntfy-sh auth database was not created"
          exit 1
        fi

        NTFY_PASSWORD="$(cat ${config.age.secrets.ntfy_password.path})" \
        ${pkgs.ntfy-sh}/bin/ntfy user add \
          --role=admin \
          --ignore-exists \
          ${cfg.username}
      '';
    };

    # Cloudflared ingress — only when a public domain is configured.
    # Requires the service-cloudflared module to be imported on this host.
    # ntfy's built-in require-login handles web UI authentication.
    services.cloudflared = mkIf (cfg.domain != null) {
      tunnels."${config.networking.hostName}" = {
        ingress."${cfg.domain}" = "http://127.0.0.1:${toString cfg.port}";
      };
    };
  };
}
