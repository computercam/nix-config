{ ... }:
{
  imports = [ ./modules.nix ];

  config = {
    services.desktopManager.plasma6.enable = true;
  };
}
