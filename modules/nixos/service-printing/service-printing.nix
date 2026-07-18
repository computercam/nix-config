# CUPS printing support.
# Drivers default to gutenprint + hplip for broad printer coverage.
# Add more via cfg.printing.drivers in your host config.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.cfg.printing;
in
{
  options.cfg.printing = {
    drivers = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        gutenprint
        hplip
      ];
      description = ''
        Printer drivers to install. Defaults to gutenprint + hplip for broad coverage.
        Add vendor-specific drivers as needed:
          with pkgs; [ canon-cups-ufr2 carps-cups epson-escpr epson-escpr2 splix ]
      '';
    };
  };

  config = {
    programs.system-config-printer.enable = true;

    services.printing = {
      enable = true;
      inherit (cfg) drivers;
    };

    users.users."${config.cfg.user.name}".extraGroups = [
      "lp"
      "printadmin"
      "scanner"
    ];
  };
}