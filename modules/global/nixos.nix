{
  config,
  lib,
  pkgs,
  ...
}:
{
  cfg.os.name = "nixos";
  boot.tmp.cleanOnBoot = config.cfg.boot.tmp.cleanOnBoot;
  boot.tmp.useTmpfs = config.cfg.boot.tmp.useTmpfs;
  i18n.defaultLocale = config.cfg.localization.lang;
  location.latitude = config.cfg.localization.latitude;
  location.longitude = config.cfg.localization.longitude;
  security.allowUserNamespaces = config.cfg.security.allowUserNamespaces;
  system.stateVersion = config.cfg.os.version;
  users.mutableUsers = config.cfg.users.mutableUsers;

  assertions = [
    {
      assertion = config.cfg.os.version != null;
      message = "cfg.os.version must be set (e.g. '24.11' for NixOS 24.11)";
    }
  ];

  # Shared Files so services can access them
  users.groups."${config.cfg.shareduser.group}" = { };
  users.users."${config.cfg.shareduser.name}" = {
    group = config.cfg.shareduser.group;
    isSystemUser = true;
  };
  users.users."${config.cfg.user.name}".extraGroups = [ config.cfg.shareduser.group ];
}