{ config, pkgs, ... }:

{
  imports = [
    ../../modules/darwin/__base.nix
  ];

  config = {
    cfg.systemname = "darwin-desktop";
    nix.maxJobs = 16;
  };
}
