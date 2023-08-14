{ config, lib, pkgs, home-manager, ... }: {
  imports = [ ./options.nix ];
  age.identityPaths = [ REPO/_/id_rsa ];
  environment.systemPackages = with pkgs; [ nixfmt git vim age ];
  environment.variables.LANG = config.cfg.localization.lang;
  networking.hostName = config.cfg.os.hostname;
  nix.extraOptions = "experimental-features = nix-command flakes";
  nix.package = pkgs.nixUnstable;
  nix.settings.auto-optimise-store = true;
  nixpkgs.config.allowUnfree = true;
  time.timeZone = config.cfg.localization.timezone;
}
