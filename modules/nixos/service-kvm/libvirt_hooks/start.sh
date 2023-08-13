#!/run/current-system/sw/bin/bash
set -x

source /var/lib/libvirt/hooks/kvm.sh

stop_display_manager

toggle_vtconsoles "unbind"
sleep "1"

toggle_efiframebuffer "unbind"
sleep "2"

toggle_gpu_modules "unload"

toggle_pci_devices "detach"

toggle_vfio_modules "load"

exit 0