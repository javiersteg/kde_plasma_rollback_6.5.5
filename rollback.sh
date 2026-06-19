#!/bin/bash
# Revert KWin + KScreen to 6.5.5 from local cache. KWin 6.7.0 breaks Wayland with DisplayLink (evdi).
# kscreenlocker stays at 6.7.0 (required by plasma-workspace >= 6.7.0).
# Rest of Plasma stays at whatever Neon offers.

set -e

echo "Starting KWin + KScreen downgrade to 6.5.5..."

# Re-enable Neon repo if disabled
if [ -f /etc/apt/sources.list.d/neon.sources.disabled ]; then
    echo "Re-enabling Neon repository..."
    sudo mv /etc/apt/sources.list.d/neon.sources.disabled /etc/apt/sources.list.d/neon.sources
fi

sudo apt update

# Hold kwin + kscreen so apt upgrade skips them
echo "Holding KWin and KScreen packages..."
sudo apt-mark hold \
    kwin-common kwin-data kwin-wayland kwin-x11 kwin-x11-common kwin-style-breeze \
    kscreen

# Upgrade everything else to latest (includes kscreenlocker -> 6.7.0)
echo "Upgrading non-held packages..."
sudo apt upgrade -y

# Prepare local downgrade directory
DOWNGRADE_DIR="$HOME/downgrade_plasma_rescue"
mkdir -p "$DOWNGRADE_DIR"
rm -f "$DOWNGRADE_DIR"/*.deb
cp /var/cache/apt/archives/kwin*6.5.5*.deb "$DOWNGRADE_DIR/" 2>/dev/null
cp /var/cache/apt/archives/kscreen_*6.5.5*.deb "$DOWNGRADE_DIR/" 2>/dev/null
rm -f "$DOWNGRADE_DIR"/*i386*.deb

# Unhold kscreen so apt can downgrade it
sudo apt-mark unhold kscreen

echo "Installing KWin + KScreen 6.5.5 from cache..."
cd "$DOWNGRADE_DIR"
sudo apt install \
    ./kwin-common_4%3a6.5.5*.deb \
    ./kwin-data_4%3a6.5.5*.deb \
    ./kwin-wayland_4%3a6.5.5*.deb \
    ./kwin-x11_4%3a6.5.5*.deb \
    ./kwin-x11-common_4%3a6.5.5*.deb \
    ./kwin-style-breeze_4%3a6.5.5*.deb \
    ./kscreen_4%3a6.5.5*.deb \
    --allow-downgrades -y

# Re-apply hold
sudo apt-mark hold \
    kwin-common kwin-data kwin-wayland kwin-x11 kwin-x11-common kwin-style-breeze \
    kscreen

echo "Done. Run: sudo reboot"
