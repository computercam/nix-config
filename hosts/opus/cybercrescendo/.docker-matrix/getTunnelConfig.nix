{ lib, pkgs, conf, ... }:

with lib;
with pkgs.stdenv;

''
ingress:
  - hostname: ${conf.domain}
    service: https://${conf.domain}
  - hostname: "*.${conf.domain}"
    service: https://${conf.domain}
  - service: http_status:404
''