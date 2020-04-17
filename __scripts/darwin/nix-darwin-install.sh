#!/usr/bin/env bash

user=`whoami`

if [[ ! -e "/Users/$user/.nix-profile/bin/nix-build" ]];
then
  echo "nix-build command not availible."
  echo "Have you already installed nix?"
  echo "Exiting . . ."
  exit 1
fi

if [[ ! -e "/run/current-system/sw/bin/darwin-rebuild" ]];
then
  nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
  ./result/bin/darwin-installer
else
  echo "nix-darwin appears to already be installed."
  echo "Exiting . . ."
  exit 0
fi
