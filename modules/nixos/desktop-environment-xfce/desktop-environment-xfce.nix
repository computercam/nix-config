{ ... }:
{
  imports = [ ./modules.nix ];

  config = {
    services.desktopManager.xfce.enable = true;
  };
}
