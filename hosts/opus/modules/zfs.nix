{ config, lib, pkgs, options, ... }: {
  config = {
    boot.supportedFilesystems = [ "zfs" ];
    boot.zfs.devNodes = "/dev/disk/by-id";
    boot.zfs.forceImportRoot = false;
    networking.hostId = "619456fe";
  };
}
