{ config, lib, pkgs, options, ... }: {
  config = {
    cfg.os.hostname = "opus";
    
    cfg.networking = {
      domain_name_servers = {
        primary = "1.1.1.1";
        secondary = "1.0.0.1";
      };

      static = {
        enable = true;
        default_gateway = "192.168.0.1";
        ip_address = "192.168.0.169";
        prefix_length = 24;
        interface = "eno0";
      };
    };
  };
}
