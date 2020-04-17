#!/usr/bin/env bash

if [[ ! -d "/nix" ]];
then
  echo "Nix directory not mounted or created."
  echo "Exiting. . ."
  exit 1
fi

if [[ ! -e "/nix/var/nix/profiles/system" ]];
then 
  curl -L --proto '=https' --tlsv1.2 https://nixos.org/nix/install | sh
else 
  echo "Nix appaers to already be installed."
  echo "Exiting. . ."
  exit 0
fi