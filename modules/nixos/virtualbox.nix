{ config, lib, pkgs, options, ... }:

{
  config = {
    boot.kernelModules = [ "vboxdrv" ];
    virtualisation.virtualbox.host.enable = true;
  };
}
