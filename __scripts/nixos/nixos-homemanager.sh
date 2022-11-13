#!/usr/bin/env sh
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

channel=`sudo nix-channel --list | grep nixos`
name=`[[ $channel == *"unstable" ]] && echo master || echo release`
version=`nixos-version | cut -d"." -f 1,2 | cut -d"p" -f 1`
archive=`[[ $name == *"master" ]] && echo ${name} || echo "${name}-${version}"`
url="https://github.com/nix-community/home-manager/archive/${archive}.tar.gz"

sudo nix-channel --add $url home-manager
sudo nix-channel --update