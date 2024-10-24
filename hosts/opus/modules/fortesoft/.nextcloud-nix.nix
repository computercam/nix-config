# { config, lib, pkgs, options, ... }: 
# let 
#   nextcloud_home_dir = "/Volumes/Server/cybercrescendo/nextcloud";
#   nextcloud_admin_password_file = "${nextcloud_home_dir}/.nextcloud_admin_password";
#   nextcloud_public_domain = "nextcloud.cybercrescendo.com";
#   nextcloud_private_domain = "homeserver.local";
#   nextcloud_local_port = 10000;
# in {
#   age.secrets = {
#     nextcloud_admin_password.file = ../../../secrets/nextcloud_admin_password.age;
#   };

#   ## TODO the nixos module for nextcloud does this automatically.
#   # services.postgresql = {
#   #   ensureDatabases = [ "nextcloud" ];
#   #   ensureUsers = [
#   #    { name = "nextcloud";
#   #      ensureDBOwnership = true;
#   #    }
#   #   ];
#   # };

#   # Database backups.
#   services.postgresqlBackup.databases = [config.services.nextcloud.config.dbname];

#   # Open the Nextcloud port.
#   networking.firewall.allowedTCPPorts = [ nextcloud_local_port ];

#   # Create the Nextcloud admin password file.
#   systemd.services.nextcloud-password-setup = {
#     description = "Create Nextcloud admin password file";
#     wantedBy = [ "multi-user.target" ];
#     before = [ "nextcloud-setup.service" ];
#     serviceConfig = {
#       Type = "oneshot";
#     };
#     script = ''
#       HOME_DIR="${nextcloud_home_dir}"
#       mkdir -p $HOME_DIR

#       NEXTCLOUD_ADMIN_PASSWORD=`cat ${config.age.secrets.nextcloud_admin_password.path}`
#       NEXTCLOUD_ADMIN_PASSWORD_FILE="${nextcloud_admin_password_file}"

#       echo "$NEXTCLOUD_ADMIN_PASSWORD" > $NEXTCLOUD_ADMIN_PASSWORD_FILE

#       chmod 600 $NEXTCLOUD_ADMIN_PASSWORD_FILE
#       chown -R nextcloud:nextcloud $HOME_DIR
#     '';
#   };

#   # Ensure Nextcloud admin password file exists before Nextcloud setup.
#   systemd.services."nextcloud-setup" = {
#     requires = ["nextcloud-password-setup.service"];
#     after = ["nextcloud-password-setup.service"];
#   };

#   # # Nextcloud nginx config
#   services.nginx.virtualHosts = {
#     "${nextcloud_public_domain}" = {
#       enableACME = true;
#       acmeRoot = null; # Use DNS-01 Challenge.
#       forceSSL = true;
#       listen = [ { 
#         port = nextcloud_local_port; 
#         addr = "0.0.0.0"; 
#         ssl = true;
#       } ];
#       # locations."/" = { 
#       #   proxyPass = "http://127.0.0.1:${builtins.toString nextcloud_local_port}"; 
#       #   proxyWebsockets = true; 
#       # };
#     };
#   };

#   # Cloudflared config
#   services.cloudflared = {
#     tunnels."07c9f962-1f28-42ec-bc26-f997937bc678" = {
#       ingress = {
#         "${nextcloud_public_domain}" = "https://${config.cfg.networking.static.ip_address}:${builtins.toString nextcloud_local_port}";
#       };
#       originRequest.noTLSVerify = true; # This is needed so we can use the local self-signed certificate.
#     };
#   };
  
#   # Nextcloud config
#   services.nextcloud = {
#     enable = true;
#     hostName = nextcloud_public_domain;
#     home = nextcloud_home_dir;
#     package = pkgs.nextcloud29; # Need to manually increment with every major upgrade.
#     database.createLocally = true; # Let NixOS install and configure the database automatically.
#     configureRedis = true; # Let NixOS install and configure Redis caching automatically.
#     maxUploadSize = "16G"; # Increase the maximum file upload size.
#     https = true; # Serve assets over https.

#     settings = {
#       overwriteProtocol = "https";
#       default_phone_region = "US";
#       trusted_domains = [ 
#         nextcloud_private_domain
#         config.cfg.networking.static.ip_address
#       ];
#     };

#     config = {
#       # dbuser = "nextcloud";
#       # dbpassFile = nextcloud_admin_password_file;
#       # adminuser = "root";
#       dbtype = "pgsql";
#       adminpassFile = nextcloud_admin_password_file;
#     };

#     # Suggested by Nextcloud's health check.
#     phpOptions."opcache.interned_strings_buffer" = "16";
#     appstoreEnable = true;
#   };
# }