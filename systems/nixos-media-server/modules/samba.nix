{ config, lib, pkgs, options, ... }:

with lib; {
  config = {
    environment.systemPackages = with pkgs; [ samba ];
    services.samba = {
      enable = true;
      syncPasswordsByPam = true;
      shares = {
        public = {
          path = "/srv/sharedfolders/User/Public";
          browseable = "yes";
          printable = "no";
          "inherit acls" = "yes";
          "inherit permissions" = "yes";
          "guest ok" = "no";
          "guest only" = "no";
          "read only" = "no";
          "store dos attributes" = "no";
          "create mask" = "0664";
          "force create mode" = "0664";
          "directory mask" = "0775";
          "force directory mode" = "0775";
          "hide special files" = "no";
          "follow symlinks" = "yes";
          "hide dot files" = "no";
          "valid users" = ''"user",@"user","filesshared",@"filesshared"'';
          "write list" = ''"user",@"user"'';
        };

        user = {
          path = "/srv/sharedfolders/User";
          browseable = "yes";
          printable = "no";
          "inherit acls" = "yes";
          "inherit permissions" = "yes";
          "guest ok" = "no";
          "guest only" = "no";
          "read only" = "no";
          "store dos attributes" = "no";
          "create mask" = "0664";
          "force create mode" = "0664";
          "directory mask" = "0775";
          "force directory mode" = "0775";
          "hide special files" = "no";
          "follow symlinks" = "yes";
          "hide dot files" = "no";
          "valid users" = ''"user",@"user","filesfull",@"filesfull"'';
          "write list" = ''"user",@"user"'';
        };

        rae = {
          path = "/srv/sharedfolders/User/Rae";
          browseable = "yes";
          printable = "no";
          "inherit acls" = "yes";
          "inherit permissions" = "yes";
          "guest ok" = "no";
          "guest only" = "no";
          "read only" = "no";
          "store dos attributes" = "no";
          "create mask" = "0664";
          "force create mode" = "0664";
          "directory mask" = "0775";
          "force directory mode" = "0775";
          "hide special files" = "no";
          "follow symlinks" = "yes";
          "hide dot files" = "no";
          "valid users" = ''"user",@"user","rae",@"rae"'';
          "write list" = ''"user",@"user"'';
        };
      };
    };
  };
}
