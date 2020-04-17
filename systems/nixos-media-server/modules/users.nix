{ config, lib, pkgs, options, ... }:

with lib; {
  config = {
    users = {
      groups = {
        rae = { };
        filesfull = { };
        filesshared = { };
      };
      users = {
        rae = {
          group = "rae";
          extraGroups = [ "filesshared" ];
          isNormalUser = true;
          createHome = false;
        };
        filesfull = {
          group = "filesfull";
          extraGroups = [ "filesshared" "filesfull" ];
          isNormalUser = true;
          createHome = false;
        };
        filesshared = {
          group = "filesshared";
          extraGroups = [ "filesshared" "filesfull" ];
          isNormalUser = true;
          createHome = false;
        };
      };
    };
  };
}
