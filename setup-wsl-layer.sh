#!/bin/bash
set -e

echo "Setting up WSL layer files..."

# Set execute permissions on shell scripts before copying
chmod +x /tmp/wsl-layer/opt/widit/scripts/disable_services.sh

# Copy all files from wsl-layer to their final locations
cp -r /tmp/wsl-layer/* /

echo "WSL layer setup complete!"