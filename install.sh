#!/bin/bash

# Persona 5 SDDM Theme Installer
# ------------------------------

THEME_NAME="persona5"
SDDM_THEME_DIR="/usr/share/sddm/themes"
CONFIG_DIR="/etc/sddm.conf.d"
CONFIG_FILE="$CONFIG_DIR/theme.conf.user"
DEST="$SDDM_THEME_DIR/$THEME_NAME"

# Files and folders that belong to the theme (docs and licenses included).
# Components/, Previews/, README and .git are NOT installed.
THEME_FILES=(
    Main.qml
    VirtualKeyboardPanel.qml
    OskKey.qml
    theme.conf
    metadata.desktop
    Preview.png
    Assets
    AUTHORS
    CREDITS
    COPYING
)

# 1. Check for Root
if [ "$EUID" -ne 0 ]; then
    echo "❌  Please run as root (sudo ./install.sh)"
    exit 1
fi

# Always work from the folder where this script lives
cd "$(dirname "$0")" || exit 1

# Sanity check: are we really inside the theme folder?
if [ ! -f "Main.qml" ]; then
    echo "❌  Main.qml not found. Run this script from the theme folder."
    exit 1
fi

echo "🎩  Installing Persona 5 SDDM Theme..."

# Warn (but don't stop) if the greeter looks like a Qt6 build
GREETER="$(command -v sddm-greeter || command -v sddm-greeter-qt6)"
if [ -n "$GREETER" ] && ldd "$GREETER" 2>/dev/null | grep -q "libQt6"; then
    echo "⚠️   Your SDDM greeter appears to use Qt6. This theme targets Qt5"
    echo "    (QtGraphicalEffects) and may fail to load."
fi

# 2. Create Directory
if [ -d "$DEST" ]; then
    echo "⚠️   Theme folder already exists. Overwriting..."
    rm -rf "$DEST"
fi

mkdir -p "$DEST"

# 3. Copy Files
for item in "${THEME_FILES[@]}"; do
    if [ -e "$item" ]; then
        cp -r "$item" "$DEST/"
    else
        echo "ℹ️   Skipping $item (not found)"
    fi
done

echo "✅  Files copied to $DEST"

# 4. Fix Permissions
# Folders need to be traversable, files only need to be readable.
find "$DEST" -type d -exec chmod 755 {} +
find "$DEST" -type f -exec chmod 644 {} +

echo "✅  Permissions fixed."

# 5. Activate Theme
# We create a drop-in file instead of editing /etc/sddm.conf directly.
mkdir -p "$CONFIG_DIR"

if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "$CONFIG_FILE.bak"
    echo "💾  Existing $CONFIG_FILE backed up to $CONFIG_FILE.bak"
fi

printf '[Theme]\nCurrent=%s\n' "$THEME_NAME" > "$CONFIG_FILE"

echo "✅  Theme activated in $CONFIG_FILE"

echo "----------------------------------------------------"
echo "🃏  Installation Complete! Take Your Time."
echo "    To test it now, run:"
echo "    sddm-greeter --test-mode --theme $DEST"
echo "----------------------------------------------------"