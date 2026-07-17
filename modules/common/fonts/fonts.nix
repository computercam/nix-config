# Core system fonts required for basic functionality.
# Personal fonts (nerd-fonts, inter, etc.) should be defined
# in your private config via cfg.home.extraPackages or a fonts module.
{
  pkgs,
  ...
}:
{
  fonts = {
    packages = with pkgs; [
      corefonts # Microsoft core web fonts (Arial, Times New Roman, etc.)
      dejavu_fonts # Standard Linux font with broad Unicode coverage
    ];
  };
}