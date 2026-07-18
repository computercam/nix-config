{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  # NOTE: Do NOT add editors (vim, nano, emacs, etc.) to this list — they can
  # shell out via :sh / :!cmd / M-x shell, effectively granting passwordless root.
  defaultNoPasswdCommands = [
    "/nix/var/nix/profiles/default/bin/npm"
    "/nix/var/nix/profiles/default/bin/openvpn"
    "/run/current-system/sw/bin/du"
    "/run/current-system/sw/bin/find"
    "/run/current-system/sw/bin/locate"
    "/run/current-system/sw/bin/nix-*"
    "/run/current-system/sw/bin/nixos-*"
  ];

  getSudoConfigFile =
    group:
    commands: ''
      # USER DEFINED RULES

      root ALL=(ALL) NOPASSWD: ALL

      %${group} ALL=(ALL) ALL

      ${concatStringsSep "\n" (map (cmd: "%${group} ALL=(ALL) NOPASSWD:${cmd}") commands)}
    '';
in
{
  options.cfg.sudo = {
    sudoersGroup = mkOption {
      type = types.str;
      default = "wheel";
      description = "Group that receives sudo access";
    };

    noPasswdCommands = mkOption {
      type = types.listOf types.str;
      default = defaultNoPasswdCommands;
      description = ''
        Commands that can be run via sudo without a password.
        WARNING: Never include editors (vim, nano, emacs) — they can
        spawn a root shell via :sh / :!cmd / M-x shell.
      '';
    };
  };

  config.security.sudo = {
    enable = true;
    configFile = "";
    extraRules = [ ];
    extraConfig = getSudoConfigFile config.cfg.sudo.sudoersGroup config.cfg.sudo.noPasswdCommands;
  };
}