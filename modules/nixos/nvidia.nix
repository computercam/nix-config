{ config, lib, pkgs, options, ... }:

with lib; 
{
  config = {
    services.xserver.videoDrivers = [ "nvidia" ]; # nvidia gtx 1060
    hardware.nvidia.modesetting.enable = true;
    hardware.nvidia.prime = {
        sync.enable = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
    };
  };
}