{ config, lib, pkgs, options, ... }:

with lib;

let
  fsOptionsMergerfs = [
    "defaults"
    "allow_other"
    "direct_io"
    "use_ino"
    "category.create=mfs"
    "minfreespace=4G"
  ];

  fsOptionsExternal = [
    # "grpjquota=aquota.group"
    # "usrjquota=aquota.user"
    "defaults"
    "nofail"
    "user_xattr"
    "noexec"
    "jqfmt=vfsv0"
    "acl"
  ];
in {
  config = {
    fileSystems = {
      fourTB1 = {
        device = "/dev/disk/by-label/4TBDISK1";
        mountPoint = "/srv/dev-disk-by-label-4TBDISK1";
        fsType = "ext4";
        options = fsOptionsExternal;
      };

      fourTB2 = {
        device = "/dev/disk/by-label/4TBDISK2";
        mountPoint = "/srv/dev-disk-by-label-4TBDISK2";
        fsType = "ext4";
        options = fsOptionsExternal;
      };

      eightTB1 = {
        device = "/dev/disk/by-label/8TBDISK1";
        mountPoint = "/srv/dev-disk-by-label-8TBDISK1";
        fsType = "ext4";
        options = fsOptionsExternal;
      };

      eightTB2 = {
        device = "/dev/disk/by-label/8TBDISK2";
        mountPoint = "/srv/dev-disk-by-label-8TBDISK2";
        fsType = "ext4";
        options = fsOptionsExternal;
      };

      eightTB3 = {
        device = "/dev/disk/by-label/8TBDISK3";
        mountPoint = "/srv/dev-disk-by-label-8TBDISK3";
        fsType = "ext4";
        options = fsOptionsExternal;
      };

      eightTB4 = {
        device = "/dev/disk/by-label/8TBDISK4";
        mountPoint = "/srv/dev-disk-by-label-8TBDISK4";
        fsType = "ext4";
        options = fsOptionsExternal;
      };

      eightTB5 = {
        device = "/dev/disk/by-label/8TBDISK5";
        mountPoint = "/srv/dev-disk-by-label-8TBDISK5";
        fsType = "ext4";
        options = fsOptionsExternal;
      };

      eightTB6 = {
        device = "/dev/disk/by-label/8TBDISK6";
        mountPoint = "/srv/dev-disk-by-label-8TBDISK6";
        fsType = "ext4";
        options = fsOptionsExternal;
      };

      games = {
        device =
          "/srv/dev-disk-by-label-8TBDISK1:/srv/dev-disk-by-label-8TBDISK2:/srv/dev-disk-by-label-8TBDISK3:/srv/dev-disk-by-label-8TBDISK4";
        mountPoint = "/srv/sharedfolders/Games";
        fsType = "fuse.mergerfs";
        options = fsOptionsMergerfs;
      };

      user = {
        device =
          "/srv/dev-disk-by-label-4TBDISK1:/srv/dev-disk-by-label-4TBDISK2";
        mountPoint = "/srv/sharedfolders/User";
        fsType = "fuse.mergerfs";
        options = fsOptionsMergerfs;
      };

      backup = {
        device =
          "/srv/dev-disk-by-label-8TBDISK5:/srv/dev-disk-by-label-8TBDISK6";
        mountPoint = "/srv/sharedfolders/Backup";
        fsType = "fuse.mergerfs";
        options = fsOptionsMergerfs;
      };
    };
  };
}
