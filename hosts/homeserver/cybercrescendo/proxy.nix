{ config, lib, pkgs, options, ... }: {
  age.secrets = {
    cf_account_id.file = ../../../secrets/cf_account_id.age;
    cf_account_api.file = ../../../secrets/cf_account_api.age;
    cf_account_email.file = ../../../secrets/cf_account_email.age;
  };
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = config.cfg.user.email;
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      dnsPropagationCheck = true;
      credentialFiles = {
        CF_API_EMAIL_FILE = config.age.secrets.cf_account_email.path;
        CF_API_KEY_FILE = config.age.secrets.cf_account_api.path;
      };
      # Use staging server.
      # server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    };
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts = {
      # # Hosted on domain.io
      # "nextcloud" = {
      #   serverName = "domain.io";
      #   enableACME = true;
      #   acmeRoot = null; # Use DNS-01 Challenge.
      #   forceSSL = true;
      #         # listen = [{port = 443; addr="0.0.0.0"; ssl=true;}];
      #   locations."/" = {proxyPass = "http://127.0.0.1:8080"; proxyWebsockets = true;};
      #   extraConfig = "client_max_body_size 1000M;";
      # };

      # Hosted on subdomains of domain.io
      "nextcloud.domain.io" = {
        enableACME = true;
        acmeRoot = null; # Use DNS-01 Challenge.
        forceSSL = true;
        # listen = [{port = 443; addr="0.0.0.0"; ssl=true;}];
        locations."/" = {proxyPass = "http://127.0.0.1:13378"; proxyWebsockets = true;};
      };
      
      # "jellyfin.domain.io" = {
      #   enableACME = true;
      #   acmeRoot = null; # Use DNS-01 Challenge.
      #   forceSSL = true;
      #   # listen = [{port = 443; addr="0.0.0.0"; ssl=true;}];
      #   locations."/" = {proxyPass = "http://127.0.0.1:8096"; proxyWebsockets = true;};
      # };
      # "plex.domain.io" = {
      #   enableACME = true;
      #   acmeRoot = null; # Use DNS-01 Challenge.
      #   forceSSL = true;
      #   # listen = [{port = 443; addr="0.0.0.0"; ssl=true;}];
      #   locations."/" = {proxyPass = "http://127.0.0.1:32400"; proxyWebsockets = true;};
      # };
      # "code.domain.io" = {
      #   enableACME = true;
      #   acmeRoot = null; # Use DNS-01 Challenge.
      #   forceSSL = true;
      #   # listen = [{port = 443; addr="0.0.0.0"; ssl=true;}];
      #   locations."/" = {proxyPass = "http://127.0.0.1:8444"; proxyWebsockets = true;};
      # };
    };
  };

}
