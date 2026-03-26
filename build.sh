#!/bin/bash
set -e

GODOT_VERSION="4.5.stable"
GODOT_URL="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip"
TEMPLATES_URL="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_export_templates.tpz"

# Download Godot
wget -q $GODOT_URL -O godot.zip
unzip -q godot.zip
chmod +x Godot_v${GODOT_VERSION}-stable_linux.x86_64

# Download and install export templates
wget -q $TEMPLATES_URL -O templates.tpz
mkdir -p ~/.local/share/godot/export_templates/${GODOT_VERSION}.stable
unzip -q templates.tpz -d /tmp/templates
mv /tmp/templates/templates/* ~/.local/share/godot/export_templates/${GODOT_VERSION}.stable/

# Create output dir
mkdir -p build

# Replace placeholder with the actual env var
sed -i "s|__API_URL__|${API_URL}|g" export_presets.cfg

# Export
./Godot_v${GODOT_VERSION}-stable_linux.x86_64 --headless --export-release "${EXPORT_PRESET}" ./build/index.html
