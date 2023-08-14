{ config, lib, pkgs, options, ... }: {
  imports = [ ./modules.nix ];

  config = {
    services.xserver.desktopManager.xfce.enable = true;
  };
}
