# Homebrew package manager configuration.
# Options are defined here; the actual taps/brews/casks and cleanup policy
# should be set in your private config (e.g. per-host brew module).
{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.cfg.homebrew;
in
{
  options.cfg.homebrew = {
    enable = mkEnableOption "Homebrew package manager";

    cleanup = mkOption {
      type = types.enum [ "none" "uninstall" "zap" ];
      default = "none";
      description = ''
        Cleanup mode for Homebrew on activation:
        - "none": keep all packages (safest)
        - "uninstall": remove unmanaged formulae
        - "zap": remove all unmanaged packages including casks (most destructive)
      '';
    };

    upgrade = mkOption {
      type = types.bool;
      default = false;
      description = "Upgrade all brews and casks on every activation";
    };

    taps = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Homebrew taps to add";
    };

    brews = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Homebrew formulae to install";
    };

    casks = mkOption {
      type = types.listOf (types.either types.str types.attrs);
      default = [ ];
      description = "Homebrew casks to install (strings or attrsets with name/options)";
    };
  };

  config = mkIf cfg.enable {
    homebrew = {
      enable = true;
      onActivation.cleanup = cfg.cleanup;
      onActivation.upgrade = cfg.upgrade;
      inherit (cfg) taps brews casks;
    };
  };
}