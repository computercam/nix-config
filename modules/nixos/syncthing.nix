{ config, lib, pkgs, options, ... }:
with lib;
let SyncthingUser = "user";
in {
  config = {
    services.syncthing = {
      enable = true;
      user = SyncthingUser;
      group = SyncthingUser;
      openDefaultPorts = true;
      relay = { enable = true; };
      configDir = mkIf (SyncthingUser != "syncthing")
        "/home/${SyncthingUser}/.config/syncthing";
      dataDir =
        mkIf (SyncthingUser != "syncthing") "/home/${SyncthingUser}/Sync";
    };
  };
}
