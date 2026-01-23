{
  config,
  lib,
  pkgs,
  ...
}:
{
  cfg.os.name = "nixos";
  boot.tmp.cleanOnBoot = true;
  boot.tmp.useTmpfs = true;
  i18n.defaultLocale = config.cfg.localization.lang;
  location.latitude = config.cfg.localization.latitude;
  location.longitude = config.cfg.localization.longitude;
  security.allowUserNamespaces = true;
  system.stateVersion = config.cfg.os.version;
  users.mutableUsers = true;
  # Shared Files so services can access them
  users.groups."${config.cfg.shareduser.group}" = { };
  users.users."${config.cfg.shareduser.name}" = {
    group = config.cfg.shareduser.group;
    isSystemUser = true;
  };
  users.users."${config.cfg.user.name}".extraGroups = [ config.cfg.shareduser.group ];
}
