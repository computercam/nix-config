{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {
    networking.firewall.package = pkgs.iptables;
    networking.firewall.enable = true;
  };
}
