declare -a PCI_DEVICES=(
  # lspci # - to list the pci devices
  # virsh nodedev-list --cap pci # - to find the full identifier
  $PASSTHROUGH_GPU_VIDEO
  $PASSTHROUGH_GPU_AUDIO
)
declare -a NVIDIA_GPU_MODULES=(
  nvidia_uvm
  nvidia_drm
  nvidia_modeset
  nvidia
  i2c_nvidia_gpu
  drm_kms_helper
  drm
)
declare -a AMD_GPU_MODULES=(
  drm_kms_helper
  amdgpu
  radeon
  drm
)
declare -a VFIO_MODULES=(
  vfio_iommu_type1
  vfio_pci
  vfio
)

function reverse {
  echo $(tac -s ' ' <<< $@)
}
function search_pci_devices {
  lspci -nn | grep -e $1 | grep -si $2
}
function toggle_modules {
  local action=$1
  shift
  local modules=$@

  for mod in ${modules[@]}
  do
    [[ $action == "load" ]] && modprobe $mod
    [[ $action == "unload" ]] && modprobe -r $mod
  done
}
function stop_display_manager {
  systemctl stop display-manager.service
}
function restart_display_manager {
  systemctl restart display-manager.service
}
function toggle_vtconsoles {
  for vtcon in /sys/class/vtconsole/*; 
  do
    [[ $1 == "bind" ]] && echo 1 > $vtcon/bind
    [[ $1 == "unbind" ]] && echo 0 > $vtcon/bind
  done
}
function toggle_efiframebuffer {
  echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/$1
}
function toggle_pci_devices {
  for dev in ${PCI_DEVICES[@]}
  do
    [[ $1 == "reattach" ]] && virsh nodedev-reattach $dev
    [[ $1 == "detach" ]] && virsh nodedev-detach $dev
  done
}
function toggle_gpu_modules {
  [[ `search_pci_devices "VGA" "NVIDIA"` ]] && \
    local modules=${NVIDIA_GPU_MODULES[@]}
  
  [[ `search_pci_devices "VGA" "AMD"` ]] && \
    local modules=${AMD_GPU_MODULES[@]}
  
  [[ $1 == "load" ]] && modules=`reverse $modules`

  toggle_modules $1 $modules
}
function toggle_vfio_modules {
  local modules=${VFIO_MODULES[@]}

  [[ $1 == "load" ]] && modules=`reverse $modules`

  echo 

  toggle_modules $1 $modules
}