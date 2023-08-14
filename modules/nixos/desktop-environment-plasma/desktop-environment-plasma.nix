{ config, lib, pkgs, options, ... }: {
  imports = [ ./modules.nix ];

  config = {
    services.xserver.desktopManager.plasma5.enable = true;
  };
}
