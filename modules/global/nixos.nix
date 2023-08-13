{ config, lib, pkgs, ... }: {
  cfg.os.name = "nixos";
  boot.tmp.cleanOnBoot = true;
  boot.tmp.useTmpfs = true;
  i18n.defaultLocale = config.cfg.localization.lang;
  location.latitude = config.cfg.localization.latitude;
  location.longitude = config.cfg.localization.longitude;
  nix.settings.allowed-users = [ "@wheel" ];
  security.allowUserNamespaces = true;
  # system.autoUpgrade.channel = "https://channels.nixos.org/nixos-${config.cfg.os.version}";
  # system.autoUpgrade.enable = true;
  system.stateVersion = config.cfg.os.version;
  users.mutableUsers = true;
}
