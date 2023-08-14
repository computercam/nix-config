{ config, lib, pkgs, options, ... }:
with pkgs.stdenv;
with lib; {
  imports = [ ./options.nix ];

  config.networking = mkMerge [
    (mkIf (config.cfg.networking.static.enable == true) {
      networkmanager.enable = mkForce false;
      dhcpcd.enable = mkForce false;

      defaultGateway = config.cfg.networking.static.default_gateway;

      interfaces."${config.cfg.networking.static.interface}".ipv4.addresses = [{
        address = config.cfg.networking.static.ip_address;
        prefixLength = config.cfg.networking.static.prefix_length;
      }];

      nameservers = [
        config.cfg.networking.domain_name_servers.primary
        config.cfg.networking.domain_name_servers.secondary
      ];
    })

    (mkIf (config.cfg.networking.static.enable != true) {
      networkmanager = {
        enable = true;
        ethernet.macAddress = "stable";
        wifi.macAddress = "random";
        insertNameservers = [
          config.cfg.networking.domain_name_servers.primary
          config.cfg.networking.domain_name_servers.secondary
        ];
      };
    })
  ];
}
