{ config, lib, pkgs, options, ... }: 
with lib;
let
  # remoteBackupUser = "u320463";
  # remoteBackupHost = "u320463.your-storagebox.de";
  # remoteBackupPort = "23";
  # remoteBackupRoot = "ssh://${remoteBackupUser}@${remoteBackupHost}:${remoteBackupPort}/./Backup/BorgBackup";
  localBackupRoot = "/Volumes/Backup/BorgBackup";
  localRedundantBackupRoot = "/Volumes/BulkStorage/BorgBackup";

  defaults = {
    encryption.mode = "repokey";
    encryption.passCommand = "cat ${config.age.secrets.borgbackup.path}";
    compression = "auto,lzma";
    persistentTimer = true;
    appendFailedSuffix = false;
    exclude = [ "re:^.*\.sync/" ];
    environment.BORG_RSH = ''ssh -i ${builtins.toString (./../../../../_ + "/id_rsa.borgbackup")}'';
  };
  
  ServerLocal = mkMerge [ defaults {
    paths = "/Volumes/Server";
    repo = "${localBackupRoot}/Server";
    preHook = ''
    	systemctl stop docker.socket
	    systemctl stop docker.service
    '';
    postHook = ''
    	systemctl start docker.socket
	    systemctl start docker.service
      systemctl list-units --type=service --all \
        | grep docker- \
        | tr -s " " \
        | cut -d" " -f 2  \
        | xargs systemctl restart
    '';
    startAt = "*-*-* 01:00:00";
    exclude = mkForce [ "re:^.*docker_storage_root/" ];
  }];

  RaeLocal = mkMerge [ defaults {
    paths = "/Volumes/Storage/Rae";
    repo = "${localBackupRoot}/Rae";
    startAt = "*-*-* 02:00:00";
  }];

  CameronLocal = mkMerge [ defaults {
    paths = "/Volumes/Storage/Cameron";
    repo = "${localBackupRoot}/Cameron";
    startAt = "*-*-* 03:00:00";
  }];

  ServerLocalRedundant = mkMerge [ ServerLocal {
    repo = mkForce "${localRedundantBackupRoot}/Server";
    startAt = mkForce "*-*-* 01:30:00";
  }];

  RaeLocalRedundant = mkMerge [ RaeLocal {
    repo = mkForce "${localRedundantBackupRoot}/Rae";
    startAt = mkForce "*-*-* 02:30:00";
  }];

  CameronLocalRedundant = mkMerge [ CameronLocal {
    repo = mkForce "${localRedundantBackupRoot}/Cameron";
    startAt = mkForce "*-*-* 03:30:00";
  }];

  # ServerRemote = mkMerge [ ServerLocal {
  #   repo = mkForce "${remoteBackupRoot}/Server";
  #   startAt = mkForce "*-*-* 01:30:00";
  # }];

  # RaeRemote = mkMerge [ RaeLocal {
  #   repo = mkForce "${remoteBackupRoot}/Rae";
  #   startAt = mkForce "*-*-* 02:30:00";
  # }];

  # CameronRemote = mkMerge [ CameronLocal {
  #   repo = mkForce "${remoteBackupRoot}/Cameron";
  #   startAt = mkForce "*-*-* 03:30:00";
  # }];

in {
  config = {
    age.identityPaths = [ ../../../../_/id_rsa.borgbackup ];
    age.secrets.borgbackup.file = ../../../../secrets/borgbackup.age;

    # TODO: not sure if this is needed since these files almost never change
    # services.cron.systemCronJobs = [
    #   "0 5 * * 0  root   rsync -avh  --min-size=1  /Volumes/BulkStorage/ /Volumes/Backup/BulkStorage/"
    # ]; 

    services.borgbackup = {
      jobs = {
        CameronLocal = CameronLocal;
        CameronLocalRedundant = CameronLocalRedundant;
        RaeLocal = RaeLocal;
        RaeLocalRedundant = RaeLocalRedundant;
        ServerLocal = ServerLocal;
        ServerLocalRedundant = ServerLocalRedundant;
      };
    };
  };
}
