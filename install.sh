#!/bin/bash

# Persona 5 SDDM Theme Installer
# ------------------------------

THEME_NAME="persona5"
SDDM_THEME_DIR="/usr/share/sddm/themes"
CONFIG_DIR="/etc/sddm.conf.d"

# 1. Check for Root
if [ "$EUID" -ne 0 ]; then
  echo "❌  Please run as root (sudo ./install.sh)"
  exit
fi

echo "🎩  Installing Persona 5 SDDM Theme..."

# 2. Create Directory
if [ -d "$SDDM_THEME_DIR/$THEME_NAME" ]; then
    echo "⚠️   Theme folder already exists. Overwriting..."
    rm -rf "$SDDM_THEME_DIR/$THEME_NAME"
fi

mkdir -p "$SDDM_THEME_DIR/$THEME_NAME"

# 3. Copy Files
# We exclude the .git folder and this script itself
cp -r * "$SDDM_THEME_DIR/$THEME_NAME/"
# Remove script from destination just to be clean
rm "$SDDM_THEME_DIR/$THEME_NAME/install.sh" 2>/dev/null

echo "✅  Files copied to $SDDM_THEME_DIR/$THEME_NAME"

# 4. Fix Permissions
# SDDM needs to read these files. Recursively set read permissions.
chmod -R 755 "$SDDM_THEME_DIR/$THEME_NAME"

echo "✅  Permissions fixed."

# 5. Activate Theme
# We create a drop-in file instead of editing /etc/sddm.conf directly.
# This is safer and cleaner.

if [ ! -d "$CONFIG_DIR" ]; then
    echo "📁  Creating config directory $CONFIG_DIR..."
    mkdir -p "$CONFIG_DIR"
fi

echo "[Theme]
Current=$THEME_NAME" > "$CONFIG_DIR/theme.conf.user"

echo "✅  Theme activated in $CONFIG_DIR/theme.conf.user"

echo "----------------------------------------------------"
echo "🃏  Installation Complete! Take Your Time."
echo "    To test it now, run: sddm-greeter --test-mode --theme $SDDM_THEME_DIR/$THEME_NAME"
echo "----------------------------------------------------"
