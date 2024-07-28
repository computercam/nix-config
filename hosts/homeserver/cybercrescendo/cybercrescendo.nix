{ config, lib, pkgs, options, ... }:
{
  imports = [ 
    ./docker.nix
    # # ./docker-swag.nix
    ./docker-nextcloud.nix
    # ./docker-gitea.nix
    ./proxy.nix
  ];
}