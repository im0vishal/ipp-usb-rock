#!/bin/sh

#set -e -x

# Create needed directories (ignore errors)
mkdir -p /etc/ipp-usb/quirks || :
mkdir -p /var/log/ipp-usb || :
mkdir -p /var/lock || :
mkdir -p /var/dev || :
mkdir -p /usr/share/ipp-usb/quirks || :

# Create log file and set permissions
LOG_FILE="/var/log/ipp-usb/main.log"
touch "$LOG_FILE"
chown 584792:584792 "$LOG_FILE"
chmod 664 "$LOG_FILE"

# Ensure config files exist
install -m 644 -D /usr/share/ipp-usb/quirks/* /etc/ipp-usb/quirks/ || :
[ ! -f /etc/ipp-usb/ipp-usb.conf ] && install -m 644 -D /usr/share/ipp-usb/ipp-usb.conf /etc/ipp-usb/

# Check if avahi-daemon is running
while ! pgrep -x "avahi-daemon" >/dev/null; do
    echo "[$(date)] Waiting for avahi-daemon to initialize..."
    sleep 1
done

echo "[$(date)] avahi-daemon is active. Starting ipp-usb..."

# Run ipp-usb and log output
exec /usr/sbin/ipp-usb "$@" 2>&1 | tee -a "$LOG_FILE"
