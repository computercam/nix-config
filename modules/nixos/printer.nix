{ config, lib, pkgs, options, ... }:

let
  PrinterDrivers = with pkgs; [
    epson-escpr
    epson-escpr2
    gutenprint
    hplip
    splix
  ];
in {
  config = {
    programs.system-config-printer.enable = true;

    services.printing = {
      enable = true;
      drivers = PrinterDrivers;
    };
  };
}
