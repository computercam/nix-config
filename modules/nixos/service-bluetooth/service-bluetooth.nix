# Bluetooth support. Separate from service-audio so hosts can opt in.
{
  config,
  lib,
  ...
}:
with lib;
{
  options.cfg.bluetooth = {
    enable = mkEnableOption "Bluetooth support";
  };

  config = mkIf config.cfg.bluetooth.enable {
    hardware.bluetooth.enable = true;
  };
}