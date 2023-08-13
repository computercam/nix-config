{ config, lib, pkgs, options, ... }: {
  config = {
    environment.systemPackages = with pkgs; [
      xorg.xkill
      xorg.xrandr
    ];

    services.xserver = {
      enable = true;
      dpi = 96;
      layout = "us";
    };
  };
}
