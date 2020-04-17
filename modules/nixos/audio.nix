{ config, lib, pkgs, ... }:

let Packages = with pkgs; [ alsaUtils pavucontrol playerctl ];
in {
  config = {
    environment.systemPackages = Packages;
    sound.enable = true;

    hardware.pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      extraModules = [ pkgs.pulseaudio-modules-bt ];

      extraConfig = ''
        load-module module-switch-on-connect
      '';

      daemon.config = {
        default-sample-format = "s24-32le";
        default-sample-rate = "44100";
      };
    };
  };
}
