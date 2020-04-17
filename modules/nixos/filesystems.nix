{ config, lib, pkgs, options, ... }:

let
  Packages = with pkgs; [
    apfs-fuse
    ddrescue
    exfat
    ext4magic
    fuse-common
    hfsprogs
    mergerfs
    mergerfs-tools
    ntfs3g
  ];
in { 
  config = { 
    environment.systemPackages = Packages; 
    
    boot.cleanTmpDir = true;
    boot.tmpOnTmpfs = true;
  }; 
}
