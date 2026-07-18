# Gaming setup: Steam, Proton, Wine, Vulkan.
# Opinionated by design — aims for a system that can run most Steam games
# and emulators out of the box.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {
    environment.systemPackages = with pkgs; [
      protontricks
      winetricks
      wine-staging
    ];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Steam Remote Play
      dedicatedServer.openFirewall = true; # Source Dedicated Server
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };

    hardware = {
      enableRedistributableFirmware = true;
      graphics.enable = true;
      graphics.enable32Bit = true;
      steam-hardware.enable = true;
    };
  };
}