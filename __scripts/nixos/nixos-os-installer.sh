#!/usr/bin/env sh
# Simple bash script to partition and install nix on a bare metal system from a Nixos live disk.
# from https://github.com/aveltras/nixos-install-script

set -e
set -u
set +x

# Configuration
FIRMWARE_TYPE=
INSTALL_DEVICE=
BOOT_PARTITION_SIZE=
SWAP_PARTITION_SIZE=

display_opt() {
    local -n ref=$2
    printf "$1: "
    if [ ! -n "$ref" ]; then
	printf "\033[31mundefined"
    else
	printf "\033[32;1m$ref"
    fi
    printf "\033[0m"
}

display_menu() {
    echo ""
    echo -e "> \033[33;1mConfigure..\033[0m"

    PS3="Please enter your choice: "
    opts=()
    opts+=("$(display_opt "Firmware type" FIRMWARE_TYPE)")
    opts+=("$(display_opt "Installation device" INSTALL_DEVICE)")

    if [ "$FIRMWARE_TYPE" == "UEFI" ]; then
	opts+=("$(display_opt "Boot partition size" BOOT_PARTITION_SIZE)")
    fi
      
    opts+=("$(display_opt "Swap partition size" SWAP_PARTITION_SIZE)")

    if ! [ -z "$INSTALL_DEVICE" ] && ! [ -z "$SWAP_PARTITION_SIZE" ]; then
	opts+=("Proceed with installation")
    fi

    select opt in "${opts[@]}"; do
	case $(echo "$opt" | cut -f1 -d":") in
	    "Firmware type") choose_firmware_type && break;;
            "Installation device") choose_device && break;;
	    "Boot partition size") choose_partition_size BOOT_PARTITION_SIZE && break;;
	    "Swap partition size") choose_partition_size SWAP_PARTITION_SIZE && break;;
	    "Proceed with installation") install && exit;;
            *) echo -e "\033[31;1mInvalid option: $REPLY\033[0m"; break;;
	esac
    done
    
    display_menu
}

display_title() {
    echo -e "\n> \033[32;1m$1\033[0m"
}

choose_firmware_type() {
    display_title "Choose firmware type"
    select firmware in "BIOS" "UEFI"; do
	if [ -n "${firmware}" ]; then
	    FIRMWARE_TYPE=${firmware} && break
	else
	    echo "Invalid option $REPLY\n"
	fi
    done
}

choose_device() {
    display_title "Available devices"
    lsblk
    
    CHOICES=($(lsblk -lndo NAME,TYPE | awk '{ if ($2 == "disk")  print $1}'))
    printf "\n> \033[33;1mChoose device\033[0m\n"
    select device in "${CHOICES[@]}"; do
	if [ -n "${device}" ]; then
	    INSTALL_DEVICE=${device} && break
	else
	    printf "Invalid option $REPLY\n"
	fi
    done
}

choose_partition_size() {
    local -n ref=$1
    units=(MB GB)
    select unit in "${units[@]}"; do
	if [ -n "${unit}" ]; then
	    printf "Partition size: "
	    read size
	    if ! [[ "$size" =~ ^[0-9]+$ ]] ; then
		echo "error: Not a number";
	    else
		ref=$size$unit
		echo "$1" && break		
	    fi
	else
	    printf "Invalid option $REPLY\n"
	fi
    done
}

hardware_uuid_to_label() {
  label=$1
  uuid=$(blkid --match-tag UUID --output value /dev/disk/by-label/"$label")
  sed -i -e "s|/dev/disk/by-uuid/$uuid|/dev/disk/by-label/$label|" /mnt/etc/nixos/hardware-configuration.nix
}

install() {

    echo "Partitioning.."
    
    if [ "$FIRMWARE_TYPE" == "UEFI" ]; then
	parted /dev/${INSTALL_DEVICE} -- mklabel gpt
	parted /dev/${INSTALL_DEVICE} -- mkpart primary ${BOOT_PARTITION_SIZE} -${SWAP_PARTITION_SIZE}
	parted /dev/${INSTALL_DEVICE} -- mkpart primary linux-swap -${SWAP_PARTITION_SIZE} 100%
	parted /dev/${INSTALL_DEVICE} -- mkpart ESP fat32 1MB ${BOOT_PARTITION_SIZE}
	parted /dev/${INSTALL_DEVICE} -- set 3 boot on
    else
	parted /dev/${INSTALL_DEVICE} -- mklabel msdos
	parted /dev/${INSTALL_DEVICE} -- mkpart primary 1MB -${SWAP_PARTITION_SIZE}
	parted /dev/${INSTALL_DEVICE} -- mkpart primary linux-swap -${SWAP_PARTITION_SIZE} 100%
    fi

    bootPartition=$(lsblk -lno NAME,MAJ:MIN | grep "${INSTALL_DEVICE}" | awk '{ id=$2; split(id,idArr,":"); if (idArr[2] == 3) print $1 }')
    swapPartition=$(lsblk -lno NAME,MAJ:MIN | grep "${INSTALL_DEVICE}" | awk '{ id=$2; split(id,idArr,":"); if (idArr[2] == 2) print $1 }')
    rootPartition=$(lsblk -lno NAME,MAJ:MIN | grep "${INSTALL_DEVICE}" | awk '{ id=$2; split(id,idArr,":"); if (idArr[2] == 1) print $1 }')

    echo "Formatting.."

    mkfs.ext4 -L nixos /dev/${rootPartition}
    mkswap -L swap /dev/${swapPartition}

    if [ "$FIRMWARE_TYPE" == "UEFI" ]; then
	mkfs.fat -F 32 -n boot /dev/${bootPartition}
    fi

    echo "Installing.."

    mount /dev/disk/by-label/nixos /mnt

    if [ "$FIRMWARE_TYPE" == "UEFI" ]; then
	mkdir -p /mnt/boot
	mount /dev/disk/by-label/boot /mnt/boot
    fi

    swapon /dev/disk/by-label/swap
    nixos-generate-config --root /mnt

    hardware_uuid_to_label nixos
    hardware_uuid_to_label swap
    hardware_uuid_to_label boot
    
    echo "Your system new is now ready to configure."
    echo "Add your settings to the configuration.nix file and then run 'nixos-install' to finish the installation."

}

display_menu
