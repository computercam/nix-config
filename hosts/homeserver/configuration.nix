{ config, pkgs, ... }:

let cfg = config.cfg;
in {
  imports = [ ./hardware-configuration.nix ./modules.nix ];
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.enable = true;
  cfg.os.version = "22.05";
  hardware.enableRedistributableFirmware = true;
  nix.autoOptimiseStore = true;
  nix.maxJobs = 8;
  programs.zsh.enable = true;
  services.fstrim.enable = true;
  users.groups.rae.name = "rae";
  users.users.rae.group = "rae";
  users.users.rae.isNormalUser = true;
  programs.nix-ld.enable = true;
}
