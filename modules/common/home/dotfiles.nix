# Automatically symlinks every file in cfg.home.dotfilesDir into the user's home
# directory, preserving the relative path structure. For example:
#
#   cfg.home.dotfilesDir = ./dotfiles;
#   ./dotfiles/.config/git/config  ->  ~/.config/git/config
#   ./dotfiles/.zshrc              ->  ~/.zshrc
#
# Set cfg.home.dotfilesDir to a directory path to enable, or null to disable.
{
  config,
  lib,
  ...
}:
with lib;
let
  # Functions [ getDir files ] taken from
  # https://github.com/Infinisil/system/blob/master/config/new-modules/default.nix

  getDir =
    dir:
    mapAttrs (file: type: if type == "directory" then getDir "${dir}/${file}" else type) (
      builtins.readDir dir
    );

  files =
    dir: collect isString (mapAttrsRecursive (path: type: concatStringsSep "/" path) (getDir dir));

  dotfiles =
    dir:
    (builtins.map (str: {
      "${str}" = {
        source = "${dir}/${str}";
      };
    }) (files dir));
in
{
  config.home-manager.users."${config.cfg.user.name}".home.file =
    mkIf (config.cfg.home.dotfilesDir != null)
    (mkMerge (dotfiles config.cfg.home.dotfilesDir));
}