{ lib, pkgs, ... }:
let

  inherit (lib) optional flatten;
  inherit (import ../channels) __nixPath;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isLinux isDarwin;

  home-manager = builtins.fetchGit { url = "https://github.com/rycee/home-manager"; };
in

{
  imports = flatten [
    (optional isDarwin "${home-manager}/nix-darwin")
    (optional isLinux "${home-manager}/nixos")
  ];

  home-manager.useUserPackages = true;
}
