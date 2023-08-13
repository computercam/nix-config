{ config, lib, pkgs, options, ... }: {
  config.services.avahi = {
    enable = true;
    nssmdns = true;

    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };
}
