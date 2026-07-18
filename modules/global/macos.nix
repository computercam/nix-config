{
  config,
  lib,
  pkgs,
  ...
}:
{
  cfg.os.name = "macos";
  system.primaryUser = config.cfg.user.name;
}