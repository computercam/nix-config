{
  config,
  lib,
  pkgs,
  ...
}:
with pkgs.stdenv;
with lib;
let
  zshInitExtra =
    if config.cfg.home.zshInitExtraConfigFile != null then
      let
        fzshInitExtraConfig = import config.cfg.home.zshInitExtraConfigFile;
        zshInitExtraConfig = fzshInitExtraConfig {
          config = config;
          lib = lib;
          pkgs = pkgs;
        };
        fgetZshInitExtra = import ./getZshInitExtra.nix;
      in
      fgetZshInitExtra {
        lib = lib;
        pkgs = pkgs;
        zshInitExtraConfig = zshInitExtraConfig;
      }
    else
      "";

in
{
  home-manager.backupCommand = "${pkgs.trash-cli}/bin/trash";
  home-manager.users."${config.cfg.user.name}" = {
    home.stateVersion = config.cfg.os.version;

    programs.git = {
      enable = true;
      settings.user.name = config.cfg.user.fullname;
      settings.user.email = config.cfg.user.email;
    };

    programs.zsh.enable = true;
    programs.zsh.initContent = zshInitExtra;

    home.packages =
      with pkgs;
      (
        if config.cfg.os.name == "nixos" then
          [
            parted # filesystems
            nettools # networking
            openvpn # networking
            killall # processes
            lshw # system info
          ]
        else if config.cfg.os.name == "macos" then
          [ ]
        else
          [ ]
      )
      ++ [
        coreutils-full # generic
        findutils # search
      ]
      ++ config.cfg.home.extraPackages;
  };
}