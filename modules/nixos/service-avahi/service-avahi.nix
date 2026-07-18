# Avahi mDNS/DNS-SD — enables .local hostname resolution on the LAN.
#
# By default, enables hostname advertising (publish.addresses + publish.domain)
# so other hosts can discover this machine by name. Extra publishing (hinfo,
# userServices, workstation) is opt-in for privacy — enable on desktops if desired.
{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.cfg.avahi;
in
{
  options.cfg.avahi = {
    publish = mkOption {
      type = types.bool;
      default = true;
      description = "Publish this host's name and addresses via mDNS (enables .local hostname discovery)";
    };

    publishHinfo = mkOption {
      type = types.bool;
      default = false;
      description = "Publish HINFO record (CPU type, OS) — minor info leak, opt-in";
    };

    publishUserServices = mkOption {
      type = types.bool;
      default = false;
      description = "Publish user-defined services via mDNS";
    };

    publishWorkstation = mkOption {
      type = types.bool;
      default = false;
      description = "Publish this host as a _workstation._tcp service";
    };
  };

  config.services.avahi = {
    enable = true;
    nssmdns4 = true;

    publish = {
      enable = cfg.publish;
      addresses = cfg.publish;
      domain = cfg.publish;
      hinfo = cfg.publishHinfo;
      userServices = cfg.publishUserServices;
      workstation = cfg.publishWorkstation;
    };
  };
}