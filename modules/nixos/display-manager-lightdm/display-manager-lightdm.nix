{ config, lib, pkgs, options, ... }: {
  config = {
    services.xserver.displayManager.lightdm.enable = true;
    services.xserver.xautolock.enable = true;
  };
}
