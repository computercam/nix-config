{ config, pkgs, ... }:

{
  imports = [
    ./modules/cron.nix
    ./modules/docker.nix
    ./modules/filesystems.nix
    ./modules/hardware-configuration.nix
    ./modules/samba.nix
    ./modules/users.nix
    ../../modules/__base.nix
    ../../modules/audio.nix
    ../../modules/desktop-applications.nix
    ../../modules/desktop.nix
    ../../modules/flatpak.nix
    ../../modules/gaming.nix
    ../../modules/multimedia.nix
    ../../modules/printer.nix
    ../../modules/nvidia.nix
    ../../modules/printer.nix
  ];

  system.stateVersion = "20.09";
  system.autoUpgrade.channel = "https://channels.nixos.org/nixos-unstable";

  networking.hostName = "microstation";
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.fstrim.enable = true; # ssd harddrives
  hardware.cpu.intel.updateMicrocode = true; # intel cpus

  hardware.enableRedistributableFirmware = true;
}
