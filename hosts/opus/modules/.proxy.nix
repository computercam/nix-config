# { config, lib, pkgs, options, ... }: {
#   age.secrets = {
#     cf_account_api.file = ../../../secrets/cf_account_api.age;
#     cf_account_email.file = ../../../secrets/cf_account_email.age;
#   };

#   security.acme = {
#     acceptTerms = true;
#     defaults = {
#       email = config.cfg.user.email;
#       dnsProvider = "cloudflare";
#       dnsResolver = "1.1.1.1:53";
#       dnsPropagationCheck = true;
#       credentialFiles = {
#         CF_API_EMAIL_FILE = config.age.secrets.cf_account_email.path;
#         CF_API_KEY_FILE = config.age.secrets.cf_account_api.path;
#       };
#     };
#   };

#   services.nginx = {
#     enable = true;
#     recommendedGzipSettings = true;
#     recommendedOptimisation = true;
#     recommendedProxySettings = true;
#     recommendedTlsSettings = true;
#   };
# }
