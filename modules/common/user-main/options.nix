{ config, lib, pkgs, ... }:
with pkgs.stdenv;
with lib; {
  options.cfg.user = {
    name = mkOption {
      type = types.str;
      default = "user";
      description = "Username for the main user on the system";
    };

    fullname = mkOption {
      type = types.str;
      default = "User";
      description = "Username for the main user on the system";
    };

    email = mkOption {
      type = types.str;
      default = "user@example.com";
      description = "Email for the main user on the system";
    };

    dotfiles = mkOption {
      type = types.str;
      default = "git@github.com:computercam/_unixconf_dotfiles.git";
      description = "dotfiles repo for the main user on the system";
    };
  };
}
