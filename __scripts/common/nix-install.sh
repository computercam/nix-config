#!/usr/bin/env bash
nix || (curl -L --proto '=https' --tlsv1.2 https://nixos.org/nix/install | sh)