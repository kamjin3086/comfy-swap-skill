<#
.SYNOPSIS
    Check comfy-swap status and report issues with solutions.
.DESCRIPTION
    Returns JSON with status and recommended actions.
#>

$result = @{
    binary_installed = $false
    binary_version = $null
    server_running = $false
    comfyui_reachable = $false
    plugin_installed = $false
    workflows_count = 0
    issues = @()
    actions = @()
}

# Check binary
try {
    $versionOutput = comfy-swap version 2>$null
    if ($versionOutput) {
        $result.binary_installed = $true
        if ($versionOutput -match '"version":\s*"([^"]+)"') {
            $result.binary_version = $Matches[1]
        }
    }
} catch {}

if (-not $result.binary_installed) {
    $result.issues += "comfy-swap binary not installed"
    $result.actions += "Run: scripts/install.ps1"
    $result | ConvertTo-Json -Depth 3
    exit 0
}

# Check server
try {
    $health = comfy-swap health 2>$null | ConvertFrom-Json
    if ($health.status -eq "ok") {
        $result.server_running = $true
        $result.comfyui_reachable = $health.comfyui.reachable
        $result.workflows_count = $health.workflows_count
    }
} catch {}

if (-not $result.server_running) {
    $result.issues += "Server not running"
    $result.actions += "Run: comfy-swap serve -d"
}

if ($result.server_running -and -not $result.comfyui_reachable) {
    $result.issues += "ComfyUI not reachable"
    $result.actions += "Run: comfy-swap config set --comfyui-url <your_comfyui_url>"
}

# Check plugin
if ($result.comfyui_reachable) {
    try {
        $pluginStatus = comfy-swap plugin-status 2>$null | ConvertFrom-Json
        if ($pluginStatus.status -eq "connected") {
            $result.plugin_installed = $true
        }
    } catch {}
    
    if (-not $result.plugin_installed) {
        $result.issues += "ComfyUI plugin not installed"
        $result.actions += "Run: comfy-swap install-plugin <custom_nodes_path>"
    }
}

# Check workflows
if ($result.workflows_count -eq 0 -and $result.plugin_installed) {
    $result.issues += "No workflows found"
    $result.actions += "Export workflow in ComfyUI, then run: comfy-swap import --sync"
}

$result | ConvertTo-Json -Depth 3
