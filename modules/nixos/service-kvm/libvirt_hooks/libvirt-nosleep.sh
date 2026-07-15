#!/bin/bash
# Inhibit host sleep while a libvirt domain is running.
#
# Starts a systemd-inhibit service when the VM begins and stops it when
# the VM ends. Requires the libvirt-nosleep@.service template to be
# configured on the host (installed automatically when "libvirt-nosleep"
# is in cfg.kvm.host.libvirtd.hooks.bundled).
#
# Arguments from libvirt:
#   $1 = domain name
#   $2 = operation (prepare, transfer, begin, end, stopped, reconnect)

DOMAIN="$1"
OPERATION="$2"

case "$OPERATION" in
  begin)
    systemctl start "libvirt-nosleep@${DOMAIN}" 2>/dev/null || true
    ;;
  stopped|end)
    systemctl stop "libvirt-nosleep@${DOMAIN}" 2>/dev/null || true
    ;;
esac

exit 0
