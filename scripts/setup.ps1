<#
.SYNOPSIS
    Complete setup: install comfy-swap, start server, configure ComfyUI.
.PARAMETER ComfyUIUrl
    ComfyUI server URL (default: http://localhost:8188)
.EXAMPLE
    .\setup.ps1
    .\setup.ps1 -ComfyUIUrl "http://192.168.1.100:8188"
#>
param(
    [string]$ComfyUIUrl = "http://localhost:8188"
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== Comfy-Swap Setup ===" -ForegroundColor Cyan

# Step 1: Install/upgrade binary
Write-Host ""
Write-Host "[1/4] Installing comfy-swap..." -ForegroundColor Yellow
& "$scriptDir\install.ps1"
if ($LASTEXITCODE -ne 0) { exit 1 }

# Step 2: Start server
Write-Host ""
Write-Host "[2/4] Starting server..." -ForegroundColor Yellow
try {
    $health = comfy-swap health 2>$null | ConvertFrom-Json
    if ($health.status -eq "ok") {
        Write-Host "Server already running."
    }
} catch {
    Write-Host "Starting daemon..."
    comfy-swap serve -d
    Start-Sleep -Seconds 2
}

# Step 3: Configure ComfyUI URL
Write-Host ""
Write-Host "[3/4] Configuring ComfyUI URL..." -ForegroundColor Yellow
comfy-swap config set --comfyui-url $ComfyUIUrl
Write-Host "ComfyUI URL set to: $ComfyUIUrl"

# Step 4: Verify
Write-Host ""
Write-Host "[4/4] Verifying setup..." -ForegroundColor Yellow
$health = comfy-swap health --pretty
Write-Host $health

# Summary
Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Ensure ComfyUI is running at $ComfyUIUrl"
Write-Host "  2. Install plugin: comfy-swap install-plugin <custom_nodes_path>"
Write-Host "  3. Export workflow in ComfyUI, then: comfy-swap import --sync"
Write-Host "  4. Run: comfy-swap run <workflow_id> prompt='...' --wait --save ./"
