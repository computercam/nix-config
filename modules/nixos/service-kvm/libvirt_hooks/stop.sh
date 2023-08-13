#!/run/current-system/sw/bin/bash

set -x

shutdown -r now

# source /var/lib/libvirt/hooks/kvm.sh

# toggle_vfio_modules "unload"

# toggle_pci_devices "reattach"

# toggle_gpu_modules "load"

# restart_display_manager

# toggle_vtconsoles "bind"

# toggle_efiframebuffer "bind"

# exit 0