{ config, lib, pkgs, ... }:

with lib;
with builtins;

let
  cfg = config.cfg.dnscrypt-proxy;

  dnscrypt-proxy = pkgs.dnscrypt-proxy2;
  dnscrypt-config = pkgs.runCommand "dnscrypt-proxy-config.toml" { } ''
    substitute ${./dnscrypt-proxy-config.toml.in} $out \
    --subst-var-by PORT '${toString cfg.port}' \
  '';

  dnscrypt-service = {
    enable = true;
    description = "dnscrypt-proxy service";

    before = [ "nss-lookup.target" ];
    wants = [ "nss-lookup.target" ];
    requires = [ "network.target" ];
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      NonBlocking = true;
      ProtectHome = true;
      ProtectControlGroups = true;
      ProtectKernelModules = true;

      ExecStart =
        "${dnscrypt-proxy}/bin/dnscrypt-proxy -config ${dnscrypt-config}";
      ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR1 $MAINPID";
      Restart = "on-failure";
    };
  };

in {

  options.cfg.dnscrypt-proxy = {
    enable = mkOption {
      default = false;
      type = with types; bool;
      description = "Enable or disable dnscrypt-proxy";
    };

    port = mkOption {
      type = types.int;
      default = 53;
      example = 5300;
      description = "Port for DNS requests";
    };
  };

  config = mkIf (cfg.enable == true) {
    systemd.services.dnscrypt-proxy = dnscrypt-service;

    networking.firewall.allowedTCPPorts = [ cfg.port ];
    networking.firewall.allowedUDPPorts = [ cfg.port ];

    networking.nameservers = [ "127.0.0.1" "::1" ];

    networking.resolvconf = {
      useLocalResolver = true;
      dnsExtensionMechanism = true;
    };

  };
}
