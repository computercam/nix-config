#!/usr/bin/env bash
DIR=`cd $(dirname "${BASH_SOURCE[0]}") && pwd`
TIMESTAMP=`date | tr -s " " "-"`
CONF="$DIR/flake.nix"

if [[ ! -n "$1" ]];
then
  echo "Hostname argument missing. Please use the name of a sub-directory under the 'hosts' folder."
  exit 1
fi
  
sudo hostname $1

if [[ ! -e "$CONF" ]];
then
  echo "'flake.nix' does not exists in $CONF"
  exit 1
fi

if [[ `uname` == "Darwin" ]];
then
  mkdir -p $HOME/.nixpkgs
  sudo ln -sf $CONF $HOME/.nixpkgs/flake.nix
fi

if [[ `uname` == "Linux" ]];
then
  sudo ln -sf $CONF /etc/nixos/flake.nix
fi