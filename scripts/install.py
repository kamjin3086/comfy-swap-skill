#!/usr/bin/env python3
"""
Install or upgrade comfy-swap CLI.

Usage:
    python install.py [version]

Examples:
    python install.py          # Install latest
    python install.py v0.1.2   # Install specific version
"""

import json
import os
import platform
import shutil
import stat
import subprocess
import sys
import urllib.request

REPO = "kamjin3086/comfy-swap"
BINARY_NAME = "comfy-swap"


def get_platform():
    """Detect OS and architecture."""
    system = platform.system().lower()
    machine = platform.machine().lower()
    
    if system == "windows":
        os_name = "windows"
    elif system == "darwin":
        os_name = "darwin"
    elif system == "linux":
        os_name = "linux"
    else:
        raise RuntimeError(f"Unsupported OS: {system}")
    
    if machine in ("x86_64", "amd64"):
        arch = "amd64"
    elif machine in ("aarch64", "arm64"):
        arch = "arm64"
    elif machine in ("i386", "i686"):
        arch = "386"
    else:
        raise RuntimeError(f"Unsupported architecture: {machine}")
    
    ext = ".exe" if os_name == "windows" else ""
    return os_name, arch, ext


def get_install_dir():
    """Get installation directory."""
    system = platform.system().lower()
    if system == "windows":
        return os.path.join(os.environ.get("LOCALAPPDATA", ""), "Microsoft", "WindowsApps")
    else:
        local_bin = os.path.expanduser("~/.local/bin")
        if os.path.isdir(local_bin) and os.access(local_bin, os.W_OK):
            return local_bin
        if os.access("/usr/local/bin", os.W_OK):
            return "/usr/local/bin"
        return local_bin


def get_latest_version():
    """Fetch latest release version from GitHub."""
    url = f"https://api.github.com/repos/{REPO}/releases/latest"
    try:
        with urllib.request.urlopen(url, timeout=30) as resp:
            data = json.loads(resp.read().decode())
            return data["tag_name"]
    except Exception as e:
        raise RuntimeError(f"Failed to fetch latest version: {e}")


def get_installed_version(binary_path):
    """Get currently installed version."""
    if not os.path.isfile(binary_path):
        return None
    try:
        result = subprocess.run(
            [binary_path, "version"],
            capture_output=True, text=True, timeout=10
        )
        output = result.stdout + result.stderr
        data = json.loads(output)
        return "v" + data.get("version", "")
    except:
        return None


def download_file(url, dest):
    """Download file from URL."""
    print(f"Downloading {url} ...")
    try:
        with urllib.request.urlopen(url, timeout=120) as resp:
            with open(dest, "wb") as f:
                shutil.copyfileobj(resp, f)
    except Exception as e:
        raise RuntimeError(f"Download failed: {e}")


def stop_running_server():
    """Stop any running comfy-swap server."""
    system = platform.system().lower()
    try:
        if system == "windows":
            subprocess.run(
                ["taskkill", "/F", "/IM", "comfy-swap.exe"],
                capture_output=True, timeout=10
            )
        else:
            subprocess.run(
                ["pkill", "-f", "comfy-swap.*serve"],
                capture_output=True, timeout=10
            )
    except:
        pass


def main():
    version = sys.argv[1] if len(sys.argv) > 1 else "latest"
    
    print("=== Comfy-Swap Installer ===")
    
    os_name, arch, ext = get_platform()
    print(f"Platform: {os_name}-{arch}")
    
    # Determine target version
    if version == "latest":
        target_version = get_latest_version()
        print(f"Latest version: {target_version}")
    else:
        target_version = version if version.startswith("v") else f"v{version}"
    
    # Check installed version
    install_dir = get_install_dir()
    binary_path = os.path.join(install_dir, BINARY_NAME + ext)
    
    installed_version = get_installed_version(binary_path)
    if installed_version:
        print(f"Installed version: {installed_version}")
        if installed_version == target_version:
            print("Already up to date.")
            return 0
        print(f"Upgrading {installed_version} -> {target_version} ...")
    else:
        print("No existing installation found.")
        print(f"Installing {target_version} ...")
    
    # Download
    download_url = f"https://github.com/{REPO}/releases/download/{target_version}/comfy-swap-{os_name}-{arch}{ext}"
    tmp_path = os.path.join(os.environ.get("TEMP", "/tmp"), f"comfy-swap-{target_version}{ext}")
    download_file(download_url, tmp_path)
    
    # Stop running server
    stop_running_server()
    
    # Install
    os.makedirs(install_dir, exist_ok=True)
    print(f"Installing to {binary_path} ...")
    
    if os.path.exists(binary_path):
        os.remove(binary_path)
    shutil.move(tmp_path, binary_path)
    
    if os_name != "windows":
        os.chmod(binary_path, os.stat(binary_path).st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
    
    # Verify
    print()
    print("Verifying installation...")
    new_version = get_installed_version(binary_path)
    if new_version:
        print(f"SUCCESS: comfy-swap {new_version} installed to {binary_path}")
        return 0
    else:
        print("ERROR: Installation verification failed")
        return 1


if __name__ == "__main__":
    sys.exit(main() or 0)
