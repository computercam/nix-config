#!/usr/bin/env bash

nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A uninstaller && ./result/bin/darwin-uninstaller
