{ config, pkgs, ... }: {
  imports = [
    ../../modules/common/home/dotfiles.nix 
    ../../modules/common/fonts/fonts.nix
    ../../modules/common/home/home.nix
    ../../modules/macos/service-homebrew/service-homebrew.nix
    ../../modules/macos/system-defaults/system-defaults.nix
    ../../modules/macos/software-brew/software-brew.nix
    ../../modules/macos/service-yabai/service-yabai.nix
  ];
}
