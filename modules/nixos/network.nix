{ config, lib, pkgs, options, ... }:
with lib;
let
  cfg = config.cfg;
in
{
  imports = [ ./dnscrypt-proxy/dnscrypt-proxy.nix ];

  config = {
    # DNSCRYPT PROXY
    cfg.dnscrypt-proxy = {
      enable = true;
      port = 53;
    };

    # NETWORK MANAGER
    networking.networkmanager = {
      enable = true;
      ethernet.macAddress = "stable";
      wifi.macAddress = "random";
    };

    # FIREWALL

    # Fail2Ban
    # Sane configurations are already enabled by default
    # Usage & Examples: https://github.com/fail2ban/fail2ban/blob/master/config/jail.conf
    services.fail2ban.enable = true;
  };
}
