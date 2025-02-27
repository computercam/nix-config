{ config, lib, pkgs, options, ... }: {
    users.groups.rae.name = "rae";
    users.users.rae.group = "rae";
    users.users.rae.isNormalUser = true;

    users.groups.sharedfiles.name = "sharedfiles";
    users.users.sharedfiles.group = "sharedfiles";
    users.users.sharedfiles.isNormalUser = true;

    users.users."${config.cfg.user.name}".extraGroups = [ "sharedfiles" ];
}
