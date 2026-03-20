#!/bin/bash
#
# Complete setup: install comfy-swap, start server, configure ComfyUI.
# Usage: ./setup.sh [comfyui_url]
# Example: ./setup.sh http://192.168.1.100:8188
#

set -e

COMFYUI_URL="${1:-http://localhost:8188}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Colors
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

info() { echo -e "${CYAN}$1${NC}"; }
step() { echo -e "${YELLOW}$1${NC}"; }
success() { echo -e "${GREEN}$1${NC}"; }

info "=== Comfy-Swap Setup ==="

# Step 1: Install/upgrade binary
echo ""
step "[1/4] Installing comfy-swap..."
bash "$SCRIPT_DIR/install.sh"

# Step 2: Start server
echo ""
step "[2/4] Starting server..."
if comfy-swap health &>/dev/null; then
    echo "Server already running."
else
    echo "Starting daemon..."
    comfy-swap serve -d
    sleep 2
fi

# Step 3: Configure ComfyUI URL
echo ""
step "[3/4] Configuring ComfyUI URL..."
comfy-swap config set --comfyui-url "$COMFYUI_URL"
echo "ComfyUI URL set to: $COMFYUI_URL"

# Step 4: Verify
echo ""
step "[4/4] Verifying setup..."
comfy-swap health --pretty

# Summary
echo ""
success "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "  1. Ensure ComfyUI is running at $COMFYUI_URL"
echo "  2. Install plugin: comfy-swap install-plugin <custom_nodes_path>"
echo "  3. Export workflow in ComfyUI, then: comfy-swap import --sync"
echo "  4. Run: comfy-swap run <workflow_id> prompt='...' --wait --save ./"
