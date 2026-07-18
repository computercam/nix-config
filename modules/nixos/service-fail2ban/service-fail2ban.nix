# fail2ban intrusion prevention framework.
#
# This module enables fail2ban and sets global defaults (bantime, findtime, etc).
# Individual service modules (e.g. service-ssh) declare their own jails via
# `services.fail2ban.jails.<name>`, gated on `config.services.fail2ban.enable`.
{ config, lib, ... }:
with lib;
let
  cfg = config.cfg.fail2ban;
in
{
  options.cfg.fail2ban = {
    enable = mkEnableOption "fail2ban intrusion prevention";

    bantime = mkOption {
      type = types.str;
      default = "1h";
      description = "Default ban duration";
    };

    findtime = mkOption {
      type = types.str;
      default = "10m";
      description = "Time window for counting failures";
    };

    maxretry = mkOption {
      type = types.int;
      default = 5;
      description = "Number of failures before banning";
    };

    ignoreIPs = mkOption {
      type = types.listOf types.str;
      default = [
        "127.0.0.1/8"
        "::1"
      ];
      description = "IPs/CIDRs to never ban";
    };
  };

  config = mkIf cfg.enable {
    services.fail2ban = {
      enable = true;
      inherit (cfg) bantime findtime maxretry;
      ignoreIP = cfg.ignoreIPs;
    };
  };
}