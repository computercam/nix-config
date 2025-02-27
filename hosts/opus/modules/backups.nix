{ config, lib, pkgs, options, ... }: 
with lib;
let 
  backupBases = [
    "/Volumes/Archive/Restic"
    "/Volumes/Backup/Restic"
  ];

  storageBase = "/Volumes/Storage";

  ResticDefaults = {
    initialize = true;
    exclude = [ ".sync" ];
    passwordFile = config.age.secrets.backup_password.path;
  };

  ResticTimerDefaults = {
    Persistent = true;
    RandomizedDelaySec = "2h";
  };

  mkResticBackup = {
    source,
    destBase ? backupBases,
    destSuffix,
    startTime,
    defaults ? ResticDefaults,
    timerDefaults ? ResticTimerDefaults,
  }: lib.listToAttrs (map (basePath: {
    # Create name using destSuffix and short hash of the full path
    name = "${builtins.replaceStrings ["/"] ["-"] destSuffix}-${builtins.substring 0 6 (builtins.hashString "sha256" basePath)}";
    value = mkMerge [ defaults {
      paths = [ source ];
      repository = "${basePath}/${destSuffix}";
      timerConfig = mkMerge [ timerDefaults {
        OnCalendar = "*-*-* ${startTime}";
      }];
    }];
  }) destBase);

  backups = {
    desktop = {
      source = "${storageBase}/Cameron/Desktop";
      destSuffix = "Cameron/Desktop";
      startTime = "01:00";
    };
    documents = {
      source = "${storageBase}/Cameron/Documents";
      destSuffix = "Cameron/Documents";
      startTime = "01:10";
    };
    downloads = {
      source = "${storageBase}/Cameron/Downloads";
      destSuffix = "Cameron/Downloads";
      startTime = "01:20";
    };
    music = {
      source = "${storageBase}/Cameron/Music";
      destSuffix = "Cameron/Music";
      startTime = "01:30";
    };
    pictures = {
      source = "${storageBase}/Cameron/Pictures";
      destSuffix = "Cameron/Pictures";
      startTime = "01:40";
    };
    movies = {
      source = "${storageBase}/Cameron/Movies";
      destSuffix = "Cameron/Movies";
      startTime = "01:50";
    };
    education = {
      source = "${storageBase}/Education";
      destSuffix = "Education";
      destBase = [ "/Volumes/Archive/Restic" ];
      startTime = "02:15";
    };
    vsts = {
      source = "${storageBase}/VSTs";
      destSuffix = "VSTs";
      destBase = [ "/Volumes/Archive/Restic" ];
      startTime = "02:30";
    };
    rae = {
      source = "${storageBase}/Rae";
      destSuffix = "Rae";
      startTime = "02:45";
    };
    server = {
      source = "/Volumes/Server";
      destBase = [ "/Volumes/Archive/Restic" ];
      destSuffix = "Server";
      startTime = "02:00";
      defaults = mkMerge [ ResticDefaults {
        backupPrepareCommand = ''
          systemctl stop docker.socket
          systemctl stop docker.service
          systemctl stop gitea.service
          systemctl stop resilio.service
        '';
        backupCleanupCommand = ''
          systemctl start docker.socket
          systemctl start docker.service
          systemctl start gitea.service
          systemctl start resilio.service
        '';
      }];
    };
  };

in {
  config = {
    age.secrets.backup_password.file = ../../../secrets/backup_password.age;
    services.restic.backups = mkMerge (map mkResticBackup (builtins.attrValues backups));
  };
}
