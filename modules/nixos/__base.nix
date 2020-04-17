{ config, lib, pkgs, options, ... }:
with lib; with pkgs.stdenv;
let
  cfg = config.cfg;
in
{
  imports = [
    ../common/__base.nix
    ./filesystems.nix
    ./network.nix
    ./sshd.nix
    ./syncthing.nix
    ./sudoers.nix
  ];

  config = {
    security.allowUserNamespaces = true;
    system.autoUpgrade.enable = true;

    users = {
      mutableUsers = true;
      
      groups = mkMerge [
        { "${cfg.username}" = { }; }
      ];

      users."${cfg.username}" = mkMerge [
        {
          group = "${cfg.username}";
          extraGroups = [
            "wheel"
            "audio"
            "docker"
            "lp"
            "networkmanager"
            "syncthing"
            "scanner"
            "sshusers"
            "vboxusers"
            "wireshark"
            "printadmin"
          ];
          initialHashedPassword = "$6$a0bnUMm2gT7nX$dBvir2R9bd6XuPnVzOFzkBMRvGKEjDHdXH9VTz/IfmLZ.IXBBPmE5UZRsAbO1luhADwESENO9n.lqltQxQQe7/";
          isNormalUser = true;
          createHome = true;
        }
      ];

      defaultUserShell = pkgs.zsh;
    };
  };
}
