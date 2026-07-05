{
  pkgs,
  ...
}:
{
  config = {
    environment.systemPackages = with pkgs; [
      xkill
      xrandr
    ];

    services.xserver = {
      enable = true;
      dpi = 96;
      xkb.layout = "us";
    };
  };
}
