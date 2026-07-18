{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.cfg.ups = {
    enable = mkEnableOption "Network UPS Tools (NUT) UPS monitoring";

    driver = mkOption {
      type = types.str;
      default = "usbhid-ups";
      description = "NUT driver for the UPS device. Use 'usbhid-ups' for most USB-connected CyberPower and APC units.";
    };

    port = mkOption {
      type = types.str;
      default = "auto";
      description = "Port the UPS is connected on. Use 'auto' for USB auto-detection.";
    };

    vendorid = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "USB vendor ID to match (e.g. '0764' for CyberPower). Leave null for auto-detection.";
    };

    productid = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "USB product ID to match. Leave null for auto-detection.";
    };

    serial = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "UPS serial number to match (for multi-USB systems). Leave null if only one UPS is connected.";
    };

    shutdownEarly = mkOption {
      type = types.bool;
      default = false;
      description = "Shut down the system as soon as the UPS goes on battery, instead of waiting for low battery.";
    };

    powerOffUPS = mkOption {
      type = types.bool;
      default = true;
      description = "Power off the UPS after the system shuts down. Ensures the UPS turns off and restores power cleanly when AC returns.";
    };

    maxStartDelay = mkOption {
      type = types.int;
      default = 45;
      description = "Maximum time (seconds) to wait before starting the UPS driver at boot.";
    };

    passwordAgePath = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Path to an age-encrypted file containing the NUT upsmon password.
        When set, the password is decrypted at runtime via agenix instead of
        being stored as plaintext in the world-readable Nix store.
      '';
    };

    pollInterval = mkOption {
      type = types.int;
      default = 5;
      description = "Polling interval in seconds for the UPS driver.";
    };
  };
}
