{ ... }:
{
  config = {
    services.displayManager.lightdm.enable = true;
    services.xserver.xautolock.enable = true;
  };
}
