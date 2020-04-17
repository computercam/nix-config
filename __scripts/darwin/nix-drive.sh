#!/usr/bin/env bash
# - - - - - - - - - - - - - - 
# Edit this value to be the apfs parition you want /nix to be mounted on
DISK_PART=""
# - - - - - - - - - - - - - - 

if [[ "$DISK_PART" != "" ]];
then
  if [[ ! -e "$DISK_PART" ]];
  then 
    echo "The path \"$DISK_PART\" provided for DISK_PART doesn't exist"
    echo "Please specify a path such as /dev/disk1s2 before continuing."
    echo "Exiting . . ."
    exit 1
  fi

  if [[ -d "/nix" ]]; 
  then
    echo "Nix directory already present at /nix."
    echo "Please rename or delete the directory before continuing."
    echo "Exiting. . ."
    exit 1
  fi

  diskutil apfs addVolume $DISK_PART APFSX Nix -mountpoint /nix
  diskutil enableOwnership /nix
  chflags hidden /nix
  echo "LABEL=Nix /nix apfs rw" | tee -a /etc/fstab
else
  echo "You need to set the value of DISK_PART to the partition of your \"Apple - Data\" volume."
  echo "You can find your partitions by running \"diskutil list\"."
  echo "It should be something like \"/dev/disk1s2\"."
  echo;
  echo "ALERT ALERT ALERT: Before running this script, ensure you are using the correct partition!!!"
  echo "Using the wrong partition could potentially bork your HD!!!"
fi
