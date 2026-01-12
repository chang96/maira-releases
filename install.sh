#!/bin/bash

# --- Configuration ---
REPO="chang96/maira-releases"
TOOL_NAME="maira-cli"
INSTALL_DIR="/usr/local/bin"
# ---------------------

# 1. Detect OS
OS_TYPE=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OS_TYPE" in
  linux*)  ASSET_NAME="maira-cli-linux-x64" ;;
  darwin*) ASSET_NAME="maira-cli-macos-x64" ;;
  msys*|cygwin*|mingw*) ASSET_NAME="maira-cli-windows-x64.exe" ;;
  *) echo "Unsupported OS: $OS_TYPE"; exit 1 ;;
esac

# 2. Construct Download URL
DOWNLOAD_URL="https://github.com/chang96/maira-releases/releases/latest/download/"

# 3. Download the executable
echo "Downloading $TOOL_NAME for $OS_TYPE..."
# Use -L to follow redirects and --fail to exit on 404 errors
curl -fsSL "$DOWNLOAD_URL$ASSET_NAME" -o "$TOOL_NAME"

if [ $? -ne 0 ]; then
    echo "Error: Could not download $ASSET_NAME. Check if the release exists."
    exit 1
fi

# 4. Install
chmod +x "$TOOL_NAME"
echo "Installing to $INSTALL_DIR (may require password)..."
sudo mv "$TOOL_NAME" "$INSTALL_DIR/$TOOL_NAME"

echo "Successfully installed $TOOL_NAME!"
