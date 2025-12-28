#!/bin/bash
# OCuLink GPU Hot-plug Safety Installation Script

set -e

echo "🔌 OCuLink GPU Hot-plug Safety Setup"
echo "===================================="
echo

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root (use sudo)"
    exit 1
fi

echo "📁 Installing files..."
SRC_DIR=$( realpath $(dirname -- "${BASH_SOURCE[0]}") )

# Install scripts
if [ ! -d /usr/local/bin ]; then
    install -m 755 -o root -g root -d /usr/local/bin
fi
install -m 755 "${SRC_DIR}/oculink-gpu-manager" /usr/local/bin/
install -m 755 "${SRC_DIR}/oculink-gpu-watcher" /usr/local/bin/
install -m 755 "${SRC_DIR}/oculink-reconnect-monitor" /usr/local/bin/
install -m 755 "${SRC_DIR}/oculink-removal-watcher" /usr/local/bin/
install -m 755 "${SRC_DIR}/oculink-kernel-config" /usr/local/bin/
install -m 755 "${SRC_DIR}/gpu-safe-remove" /usr/local/bin/
if [ ! -d /usr/local/share ]; then
    install -m 755 -o root -g root -d /usr/local/share
    if [ ! -d /usr/local/share/oculink-hotplug ]; then
        install -m 755 -o root -g root -d /usr/local/share/oculink-hotplug
    fi
fi
install -m 755 "${SRC_DIR}/oculink-hotplug.library" /usr/local/share/oculink-hotplug/


# Install udev rules
install -m 644 "${SRC_DIR}/99-oculink-gpu-hotplug.rules" /etc/udev/rules.d/

# Install systemd services
install -m 644 "${SRC_DIR}/oculink-gpu-monitor.service" /etc/systemd/system/
install -m 644 "${SRC_DIR}/oculink-kernel-safety.service" /etc/systemd/system/

echo "🔄 Reloading system configuration..."

# Reload udev rules
udevadm control --reload-rules
udevadm trigger

# Reload and enable systemd services
systemctl daemon-reload
systemctl enable oculink-gpu-monitor.service
systemctl enable oculink-kernel-safety.service
systemctl restart oculink-gpu-monitor.service
systemctl restart oculink-kernel-safety.service

# Create log directory
#mkdir -p /var/log
#touch /var/log/oculink-gpu-manager.log
#touch /var/log/oculink-gpu-watcher.log
#touch /var/log/oculink-reconnect.log
#touch /var/log/oculink-removal-watcher.log
#chmod 644 /var/log/oculink-*.log

echo "✅ Installation complete!"
echo
echo "📋 Usage:"
echo "   • Automatic: GPU will be safely prepared when unplugged"
echo "   • Manual: Run 'gpu-safe-remove' before unplugging"
echo "   • Smart reconnection: Auto-detects when you plug it back in"
#echo "   • Logs: Check /var/log/oculink-*.log for details"
echo "   • Monitor status: 'oculink-reconnect-monitor status'"
echo
echo "🔍 Service status:"
systemctl status oculink-gpu-monitor.service --no-pager -l

echo
echo "⚠️  Important notes:"
echo "   • Always wait for the 'safe to unplug' notification"
echo "   • The system may temporarily restart your compositor"
echo "   • GPU-intensive apps will be closed during removal"
