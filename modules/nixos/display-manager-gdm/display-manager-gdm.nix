{ config, lib, pkgs, options, ... }: {
  config = {
    services.xserver.displayManager.gdm.enable = true;
  };
}
