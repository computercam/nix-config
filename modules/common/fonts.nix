{ config, lib, pkgs, options, ... }:
let
  Packages = with pkgs; [
    corefonts
    dejavu_fonts
    fantasque-sans-mono
    fira
    fira-code
    freefont_ttf
    gyre-fonts
    liberation_ttf
    terminus-nerdfont
    noto-fonts
    noto-fonts-emoji
    ubuntu_font_family
    unifont
    victor-mono
  ];
in {
  config = {
    fonts = {
      fonts = Packages;
      enableFontDir = true;
    };
  };
}
