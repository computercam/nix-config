#!/bin/bash
# Generic PCI passthrough hook for libvirt QEMU domains.
#
# When a VM with PCI hostdevs starts, this hook:
# 1. Records the current driver binding for each PCI hostdev
# 2. Unbinds the device from its current driver
# 3. Binds it to vfio-pci
#
# When the VM stops, this hook:
# 1. Unbinds the device from vfio-pci
# 2. Rebinds it to the original driver
#
# For devices that are always bound to vfio-pci at boot (via modprobe config),
# this hook is a no-op.
#
# Arguments from libvirt:
#   $1 = domain name
#   $2 = operation (prepare, transfer, begin, end, stopped, reconnect)
#   $3 = sub-operation (e.g. "start", "stopped")

set -euo pipefail

DOMAIN="$1"
OPERATION="$2"
STATEDIR="/run/libvirt-vfio"

# Extract PCI BDF addresses (DDDD:BB:DD.F) from the domain's hostdev entries.
# Libvirt XML: <address domain='0x0000' bus='0x01' slot='0x00' function='0x0'/>
get_hostdev_pcis() {
  virsh dumpxml "$DOMAIN" 2>/dev/null | \
    sed -n "s/.*domain='0x\([0-9a-f]*\)' bus='0x\([0-9a-f]*\)' slot='0x\([0-9a-f]*\)' function='0x\([0-9a-f]*\).*/\1:\2:\3.\4/p"
}

# Get the driver currently bound to a PCI device.
get_driver() {
  local pci="$1"
  local link="/sys/bus/pci/devices/${pci}/driver"
  if [ -L "$link" ]; then
    basename "$(readlink -f "$link")"
  fi
}

unbind_to_vfio() {
  local pci="$1"
  local driver
  driver=$(get_driver "$pci") || true
  if [ "$driver" = "vfio-pci" ]; then
    return 0
  fi
  mkdir -p "$STATEDIR"
  if [ -n "$driver" ]; then
    echo "gpu-passthrough: unbinding ${pci} from ${driver}"
    echo "$pci" > "/sys/bus/pci/drivers/${driver}/unbind" 2>/dev/null || true
    echo "$driver" > "$STATEDIR/${DOMAIN}-${pci}"
  fi
  echo "gpu-passthrough: binding ${pci} to vfio-pci"
  echo "$pci" > "/sys/bus/pci/drivers/vfio-pci/bind" 2>/dev/null || true
}

rebind_from_vfio() {
  local pci="$1"
  local statefile="$STATEDIR/${DOMAIN}-${pci}"
  if [ ! -f "$statefile" ]; then
    return 0
  fi
  local driver
  driver=$(cat "$statefile")
  echo "gpu-passthrough: rebinding ${pci} to ${driver}"
  echo "$pci" > "/sys/bus/pci/drivers/vfio-pci/unbind" 2>/dev/null || true
  if [ -d "/sys/bus/pci/drivers/${driver}" ]; then
    echo "$pci" > "/sys/bus/pci/drivers/${driver}/bind" 2>/dev/null || true
  fi
  rm -f "$statefile"
}

case "$OPERATION" in
  begin)
    mkdir -p "$STATEDIR"
    for pci in $(get_hostdev_pcis); do
      unbind_to_vfio "$pci"
    done
    ;;
  stopped|end)
    for pci in $(get_hostdev_pcis); do
      rebind_from_vfio "$pci"
    done
    ;;
esac

exit 0
