#!/bin/bash
# Revert KDE Plasma to version 6.5.5 from local cache due to KWin 6.7.0 Wayland/DisplayLink issues.

echo "Starting Plasma downgrade to 6.5.5..."

# Disable Neon repository to prevent apt from resolving dependencies with 6.7.0
if [ -f /etc/apt/sources.list.d/neon.sources ]; then
    echo "Disabling Neon repository..."
    sudo mv /etc/apt/sources.list.d/neon.sources /etc/apt/sources.list.d/neon.sources.disabled
    sudo apt update
fi

# Set up local downgrade directory
DOWNGRADE_DIR="$HOME/downgrade_plasma_rescue"
echo "Preparing local packages in $DOWNGRADE_DIR..."
mkdir -p "$DOWNGRADE_DIR"
rm -f "$DOWNGRADE_DIR"/*.deb

# Copy 6.5.5 and 6.6.x cached packages, excluding 32-bit (i386)
cp /var/cache/apt/archives/*6.5.5*.deb "$DOWNGRADE_DIR/" 2>/dev/null
cp /var/cache/apt/archives/*6.6.5*.deb "$DOWNGRADE_DIR/" 2>/dev/null
rm -f "$DOWNGRADE_DIR"/*i386*.deb

# Force downgrade from local deb files
echo "Installing 6.5.5 packages..."
cd "$DOWNGRADE_DIR" || exit 1

sudo apt install \
  ./breeze_4%3a6.5.5*.deb \
  ./breeze-cursor-theme_4%3a6.5.5*.deb \
  ./kde-style-breeze_4%3a6.5.5*.deb \
  ./kde-style-oxygen_4%3a6.5.5*.deb \
  ./kde-style-oxygen-qt5_4%3a6.5.5*.deb \
  ./liboxygenstyle5_4%3a6.5.5*.deb \
  ./liboxygenstyle5-5_4%3a6.5.5*.deb \
  ./liboxygenstyle6_4%3a6.5.5*.deb \
  ./liboxygenstyleconfig5-5_4%3a6.5.5*.deb \
  ./liboxygenstyleconfig6_4%3a6.5.5*.deb \
  ./kwayland_4%3a6.5.5*.deb \
  ./kwayland-integration_4%3a6.5.5*.deb \
  ./kwin-common_4%3a6.5.5*.deb \
  ./kwin-data_4%3a6.5.5*.deb \
  ./kwin-wayland_4%3a6.5.5*.deb \
  ./kwin-x11_4%3a6.5.5*.deb \
  ./kwin-x11-common_4%3a6.5.5*.deb \
  ./kwin-style-breeze_4%3a6.5.5*.deb \
  ./kwin-decoration-oxygen_4%3a6.5.5*.deb \
  ./plasma-theme-oxygen_4%3a6.5.5*.deb \
  ./oxygen_4%3a6.5.5*.deb \
  ./kscreen_4%3a6.5.5*.deb \
  ./kscreenlocker_6.5.5*.deb \
  ./libplasma6_6.5.5*.deb \
  ./plasma-workspace_4%3a6.5.5*.deb \
  ./plasma-desktop_4%3a6.5.5*.deb \
  ./plasma-integration_6.5.5*.deb \
  ./plasma-pa_4%3a6.5.5*.deb \
  ./plasma-nm_4%3a6.5.5*.deb \
  ./plasma5support_6.5.5*.deb \
  ./powerdevil_4%3a6.5.5*.deb \
  ./powerdevil-data_4%3a6.5.5*.deb \
  ./libpowerdevilcore2_4%3a6.5.5*.deb \
  ./sddm-theme-breeze_4%3a6.5.5*.deb \
  ./xdg-desktop-portal-kde_6.5.5*.deb \
  --allow-downgrades -y

# Hold packages to prevent future upgrades to 6.7.0
echo "Applying apt-mark hold to Plasma packages..."
sudo apt-mark hold \
  kwin-common kwin-data kwin-wayland kwin-x11 kwin-x11-common kwin-style-breeze \
  kscreen kscreenlocker libplasma6 plasma-workspace plasma-desktop

echo "Downgrade complete. Please run: sudo reboot"
