{ config, lib, pkgs, options, ... }:
{
  imports = [
    ./docker.nix
    # ./docker-gitea.nix
    ./docker-nextcloud.nix
    ./proxy.nix
  ];
}