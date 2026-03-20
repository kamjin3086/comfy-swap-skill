#!/bin/bash
#
# Install or upgrade comfy-swap CLI on Linux/macOS.
# Usage: ./install.sh [version]
# Example: ./install.sh v0.1.2
#

set -e

REPO="kamjin3086/comfy-swap"
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="comfy-swap"
VERSION="${1:-latest}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

info() { echo -e "${CYAN}$1${NC}"; }
success() { echo -e "${GREEN}$1${NC}"; }
error() { echo -e "${RED}$1${NC}" >&2; exit 1; }

# Detect OS and architecture
detect_platform() {
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)
    
    case "$OS" in
        linux) OS="linux" ;;
        darwin) OS="darwin" ;;
        *) error "Unsupported OS: $OS" ;;
    esac
    
    case "$ARCH" in
        x86_64|amd64) ARCH="amd64" ;;
        aarch64|arm64) ARCH="arm64" ;;
        *) error "Unsupported architecture: $ARCH" ;;
    esac
    
    echo "${OS}-${ARCH}"
}

# Get latest version from GitHub
get_latest_version() {
    curl -s "https://api.github.com/repos/$REPO/releases/latest" | \
        grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

# Get installed version
get_installed_version() {
    if command -v $BINARY_NAME &> /dev/null; then
        $BINARY_NAME version 2>/dev/null | grep -oE 'v?[0-9]+\.[0-9]+\.[0-9]+' | head -1 | sed 's/^/v/' | sed 's/^vv/v/'
    fi
}

# Download binary
download_binary() {
    local ver="$1"
    local platform="$2"
    local url="https://github.com/$REPO/releases/download/$ver/comfy-swap-$platform"
    local tmp_file="/tmp/comfy-swap-$$"
    
    info "Downloading $url ..."
    if command -v curl &> /dev/null; then
        curl -fSL "$url" -o "$tmp_file" || error "Download failed"
    elif command -v wget &> /dev/null; then
        wget -q "$url" -O "$tmp_file" || error "Download failed"
    else
        error "Neither curl nor wget found"
    fi
    
    echo "$tmp_file"
}

# Main
main() {
    info "=== Comfy-Swap Installer ==="
    
    PLATFORM=$(detect_platform)
    info "Platform: $PLATFORM"
    
    # Determine target version
    if [ "$VERSION" = "latest" ]; then
        TARGET_VERSION=$(get_latest_version)
        [ -z "$TARGET_VERSION" ] && error "Failed to fetch latest version"
        info "Latest version: $TARGET_VERSION"
    else
        TARGET_VERSION="$VERSION"
        [[ "$TARGET_VERSION" != v* ]] && TARGET_VERSION="v$TARGET_VERSION"
    fi
    
    # Check installed version
    INSTALLED_VERSION=$(get_installed_version)
    if [ -n "$INSTALLED_VERSION" ]; then
        info "Installed version: $INSTALLED_VERSION"
        if [ "$INSTALLED_VERSION" = "$TARGET_VERSION" ]; then
            success "Already up to date."
            exit 0
        fi
        info "Upgrading $INSTALLED_VERSION -> $TARGET_VERSION ..."
    else
        info "No existing installation found."
        info "Installing $TARGET_VERSION ..."
    fi
    
    # Download
    TMP_BINARY=$(download_binary "$TARGET_VERSION" "$PLATFORM")
    chmod +x "$TMP_BINARY"
    
    # Stop running server if any
    if pgrep -f "comfy-swap.*serve" > /dev/null 2>&1; then
        info "Stopping running comfy-swap server..."
        pkill -f "comfy-swap.*serve" 2>/dev/null || true
        sleep 1
    fi
    
    # Install
    INSTALL_PATH="$INSTALL_DIR/$BINARY_NAME"
    info "Installing to $INSTALL_PATH ..."
    
    if [ -w "$INSTALL_DIR" ]; then
        mv "$TMP_BINARY" "$INSTALL_PATH"
    else
        sudo mv "$TMP_BINARY" "$INSTALL_PATH"
        sudo chmod +x "$INSTALL_PATH"
    fi
    
    # Verify
    echo ""
    info "Verifying installation..."
    NEW_VERSION=$(get_installed_version)
    if [ -n "$NEW_VERSION" ]; then
        success "SUCCESS: comfy-swap $NEW_VERSION installed"
        echo ""
        echo "Next steps:"
        echo "  comfy-swap serve -d    # Start server"
        echo "  comfy-swap health      # Check status"
    else
        error "Installation verification failed"
    fi
}

main
