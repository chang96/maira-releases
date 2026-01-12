#!/bin/bash
set -euo pipefail

# --- Configuration ---
REPO="chang96/maira-releases"
TOOL_NAME="maira-cli"
INSTALL_DIR="/usr/local/bin"
TMP_DIR="/tmp"
# ---------------------

TMP_FILE="$TMP_DIR/$TOOL_NAME"

# 1. Detect OS
OS_TYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"
case "$OS_TYPE" in
  linux*)  ASSET_NAME="maira-cli-linux-x64" ;;
  darwin*) ASSET_NAME="maira-cli-macos-x64" ;;
  *)
    echo "❌ Unsupported OS: $OS_TYPE"
    exit 1
    ;;
esac

# 2. Ensure curl exists
if ! command -v curl >/dev/null 2>&1; then
  echo "❌ Error: curl is required but not installed."
  exit 1
fi

# 3. Get latest release tag
echo "🔍 Fetching latest release info..."
LATEST_TAG="$(
  curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
  | grep '"tag_name"' \
  | sed -E 's/.*"([^"]+)".*/\1/'
)"

if [ -z "$LATEST_TAG" ]; then
  echo "❌ Error: Could not determine latest release tag."
  exit 1
fi

# 4. Construct download URL
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST_TAG/$ASSET_NAME"

echo "⬇️  Downloading $TOOL_NAME ($LATEST_TAG) for $OS_TYPE..."
echo "    Source: $DOWNLOAD_URL"

# 5. Download to temp location
curl -fsSL "$DOWNLOAD_URL" -o "$TMP_FILE"

# 6. Verify download
if [ ! -s "$TMP_FILE" ]; then
  echo "❌ Error: Download failed or file is empty."
  exit 1
fi

# 7. Make executable
chmod +x "$TMP_FILE"

# 8. Install
echo "📦 Installing to $INSTALL_DIR..."
if [ -w "$INSTALL_DIR" ]; then
  mv "$TMP_FILE" "$INSTALL_DIR/$TOOL_NAME"
else
  sudo mv "$TMP_FILE" "$INSTALL_DIR/$TOOL_NAME"
fi

# 9. Verify installation
if ! command -v "$TOOL_NAME" >/dev/null 2>&1; then
  echo "❌ Installation failed: $TOOL_NAME not found in PATH."
  exit 1
fi

echo "✅ Successfully installed $TOOL_NAME!"
echo "👉 Run with: $TOOL_NAME"
