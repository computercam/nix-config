{ lib, pkgs, options, ... }:
with pkgs.stdenv;
with lib; {
  options.cfg.shell = {
    ohMyZsh = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable oh-my-zsh or not";
      };

      plugins = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "list of oh-my-zsh plugins to use";
      };
    };

    variables = mkOption {
      type = with types; attrsOf (nullOr (either str path));
      default = {};
      description = "Attrset of varibles";
    };

    aliases = mkOption {
      type = with types; attrsOf (nullOr (either str path));
      default = {};
      description = "Attrset of aliases";
    };

    setOpts = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of set options";
    };

    completions = mkOption {
      type = with types; attrsOf (nullOr (either str path));
      default = {};
      description = "Attrset of zstyle zsh completions";
    };

    keybindings = mkOption {
      type = with types; attrsOf (nullOr (either str path));
      default = {};
      description = "Attrset of zsh bindkey keybindings";
    };

    paths = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of paths to add to your $PATH";
    };

    fpaths = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of site-function paths";
    };

    sources = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of shell files to source";
    };

    extras = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Extra lines of code at the end of shell profile";
    };
  };
}
