#!/bin/bash
#
# Check comfy-swap status and report issues with solutions.
# Returns JSON with status and recommended actions.
#

# Initialize result
binary_installed=false
binary_version=""
server_running=false
comfyui_reachable=false
plugin_installed=false
workflows_count=0
issues=()
actions=()

# Check binary
if command -v comfy-swap &> /dev/null; then
    binary_installed=true
    binary_version=$(comfy-swap version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
fi

if [ "$binary_installed" = false ]; then
    issues+=("comfy-swap binary not installed")
    actions+=("Run: bash scripts/install.sh")
else
    # Check server
    health_output=$(comfy-swap health 2>/dev/null)
    if echo "$health_output" | grep -q '"status":"ok"'; then
        server_running=true
        if echo "$health_output" | grep -q '"reachable":true'; then
            comfyui_reachable=true
        fi
        workflows_count=$(echo "$health_output" | grep -oE '"workflows_count":[0-9]+' | grep -oE '[0-9]+')
    fi
    
    if [ "$server_running" = false ]; then
        issues+=("Server not running")
        actions+=("Run: comfy-swap serve -d")
    fi
    
    if [ "$server_running" = true ] && [ "$comfyui_reachable" = false ]; then
        issues+=("ComfyUI not reachable")
        actions+=("Run: comfy-swap config set --comfyui-url <your_comfyui_url>")
    fi
    
    # Check plugin
    if [ "$comfyui_reachable" = true ]; then
        plugin_output=$(comfy-swap plugin-status 2>/dev/null)
        if echo "$plugin_output" | grep -q '"status":"connected"'; then
            plugin_installed=true
        else
            issues+=("ComfyUI plugin not installed")
            actions+=("Run: comfy-swap install-plugin <custom_nodes_path>")
        fi
    fi
    
    # Check workflows
    if [ "$plugin_installed" = true ] && [ "${workflows_count:-0}" -eq 0 ]; then
        issues+=("No workflows found")
        actions+=("Export workflow in ComfyUI, then run: comfy-swap import --sync")
    fi
fi

# Output JSON
issues_json=$(printf '%s\n' "${issues[@]}" | jq -R . | jq -s .)
actions_json=$(printf '%s\n' "${actions[@]}" | jq -R . | jq -s .)

cat <<EOF
{
  "binary_installed": $binary_installed,
  "binary_version": "${binary_version:-null}",
  "server_running": $server_running,
  "comfyui_reachable": $comfyui_reachable,
  "plugin_installed": $plugin_installed,
  "workflows_count": ${workflows_count:-0},
  "issues": $issues_json,
  "actions": $actions_json
}
EOF
