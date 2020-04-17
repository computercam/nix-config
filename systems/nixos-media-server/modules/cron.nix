{ config, lib, pkgs, options, ... }:

with lib; {
  config = {
    services.cron = {
      enable = true;
      mailto = "user@example.com";
      systemCronJobs = [
        "0 */6 * * *  root  rsync -avzh --update --size-only /srv/sharedfolders/User/* /srv/sharedfolders/Backup/"
        "0 */6 * * *  root  rsync -avzh --update --size-only /home/user/.config/syncthing/* /srv/sharedfolders/Backup/"
      ];
    };
  };
}
