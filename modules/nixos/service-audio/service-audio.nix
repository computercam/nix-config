# Audio support via PipeWire (PulseAudio-compatible, JACK-optional).
# Bluetooth is in a separate module (service-bluetooth).
{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {
    environment.systemPackages = with pkgs; [ pavucontrol ];
    users.users."${config.cfg.user.name}".extraGroups = [ "audio" ];

    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;

      # Uncomment to enable JACK applications:
      # jack.enable = true;
    };
  };
}