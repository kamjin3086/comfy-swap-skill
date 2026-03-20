<# 
.SYNOPSIS
    Install or upgrade comfy-swap CLI on Windows.
.DESCRIPTION
    Downloads the latest release from GitHub and installs to WindowsApps.
    Automatically detects if upgrade is needed.
.EXAMPLE
    .\install.ps1
    .\install.ps1 -Version v0.1.2
#>
param(
    [string]$Version = "latest"
)

$ErrorActionPreference = "Stop"
$repo = "kamjin3086/comfy-swap"
$binaryName = "comfy-swap.exe"
$installDir = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
$installPath = Join-Path $installDir $binaryName

function Get-LatestVersion {
    $url = "https://api.github.com/repos/$repo/releases/latest"
    try {
        $response = Invoke-RestMethod -Uri $url -Headers @{"User-Agent"="comfy-swap-installer"}
        return $response.tag_name
    } catch {
        Write-Error "Failed to fetch latest version: $_"
        exit 1
    }
}

function Get-InstalledVersion {
    try {
        $output = & $installPath version 2>$null
        if ($output -match '"version":\s*"([^"]+)"') {
            return "v$($Matches[1])"
        }
        if ($output -match 'v?(\d+\.\d+\.\d+)') {
            return "v$($Matches[1])"
        }
    } catch {}
    return $null
}

function Download-Binary {
    param([string]$ver)
    
    $arch = if ([Environment]::Is64BitOperatingSystem) { "amd64" } else { "386" }
    $downloadUrl = "https://github.com/$repo/releases/download/$ver/comfy-swap-windows-$arch.exe"
    $tempPath = Join-Path $env:TEMP "comfy-swap-$ver.exe"
    
    Write-Host "Downloading $downloadUrl ..."
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath -UseBasicParsing
    } catch {
        Write-Error "Download failed: $_"
        exit 1
    }
    
    return $tempPath
}

# Main
Write-Host "=== Comfy-Swap Installer ===" -ForegroundColor Cyan

# Determine target version
if ($Version -eq "latest") {
    $targetVersion = Get-LatestVersion
    Write-Host "Latest version: $targetVersion"
} else {
    $targetVersion = $Version
    if (-not $targetVersion.StartsWith("v")) {
        $targetVersion = "v$targetVersion"
    }
}

# Check installed version
$installedVersion = Get-InstalledVersion
if ($installedVersion) {
    Write-Host "Installed version: $installedVersion"
    if ($installedVersion -eq $targetVersion) {
        Write-Host "Already up to date." -ForegroundColor Green
        exit 0
    }
    Write-Host "Upgrading $installedVersion -> $targetVersion ..."
} else {
    Write-Host "No existing installation found."
    Write-Host "Installing $targetVersion ..."
}

# Download and install
$tempBinary = Download-Binary -ver $targetVersion

# Stop running server if any
try {
    $procs = Get-Process -Name "comfy-swap" -ErrorAction SilentlyContinue
    if ($procs) {
        Write-Host "Stopping running comfy-swap processes..."
        $procs | Stop-Process -Force
        Start-Sleep -Seconds 1
    }
} catch {}

# Copy to install location
Write-Host "Installing to $installPath ..."
Copy-Item -Path $tempBinary -Destination $installPath -Force
Remove-Item -Path $tempBinary -Force

# Verify
Write-Host ""
Write-Host "Verifying installation..."
$newVersion = Get-InstalledVersion
if ($newVersion) {
    Write-Host "SUCCESS: comfy-swap $newVersion installed" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  comfy-swap serve -d    # Start server"
    Write-Host "  comfy-swap health      # Check status"
} else {
    Write-Error "Installation verification failed"
    exit 1
}
