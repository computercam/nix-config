{ config, lib, pkgs, options, ... }: {
  config = {
    services.xserver.displayManager.sddm.enable = true;
  };
}
