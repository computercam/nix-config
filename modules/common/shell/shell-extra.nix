{ config, lib, pkgs, options, ... }: {
  imports = [ ./options.nix ];
  
  home-manager.users."${config.cfg.user.name}".home.packages = with pkgs; [
    cmatrix 
    cowsay
    figlet
    lolcat
    pipes
    toilet
    pywal
    colorz
  ];
}

