---
name: comfy-swap
description: Use Comfy-Swap CLI to run ComfyUI workflows, manage workflow parameters, and generate images. Trigger when user asks to run ComfyUI workflows, generate AI images, list workflows, modify workflow API parameters, inspect workflow nodes, adjust parameter mappings, check generation status, view request logs, or automate image generation tasks. Also trigger when user mentions comfy-swap, ComfyUI API, or image generation pipeline.
---

# Comfy-Swap

CLI tool for running ComfyUI workflows as stable APIs. Respond in the user's language.

## Quick Check

```bash
comfy-swap health
```

| Output | Action |
|--------|--------|
| `status: ok` | Ready to use |
| Command not found | Run [Auto-Install](#auto-install-binary) |
| Connection refused | `comfy-swap serve -d` |
| `comfyui.reachable: false` | `comfy-swap config set --comfyui-url <url>` |

---

## Auto-Install Binary

**If `comfy-swap` command not found, run ONE of these scripts to install automatically:**

### Windows (PowerShell)

```powershell
$version = "v0.1.2"
$url = "https://github.com/kamjin3086/comfy-swap/releases/download/$version/comfy-swap-windows-amd64.exe"
$dest = "$env:LOCALAPPDATA\Microsoft\WindowsApps\comfy-swap.exe"
Invoke-WebRequest -Uri $url -OutFile $dest
Write-Host "Installed to $dest"
comfy-swap version
```

### Linux (amd64)

```bash
VERSION="v0.1.2"
curl -L "https://github.com/kamjin3086/comfy-swap/releases/download/$VERSION/comfy-swap-linux-amd64" -o /tmp/comfy-swap
sudo mv /tmp/comfy-swap /usr/local/bin/comfy-swap
sudo chmod +x /usr/local/bin/comfy-swap
comfy-swap version
```

### Linux (arm64)

```bash
VERSION="v0.1.2"
curl -L "https://github.com/kamjin3086/comfy-swap/releases/download/$VERSION/comfy-swap-linux-arm64" -o /tmp/comfy-swap
sudo mv /tmp/comfy-swap /usr/local/bin/comfy-swap
sudo chmod +x /usr/local/bin/comfy-swap
comfy-swap version
```

### macOS (Apple Silicon)

```bash
VERSION="v0.1.2"
curl -L "https://github.com/kamjin3086/comfy-swap/releases/download/$VERSION/comfy-swap-darwin-arm64" -o /tmp/comfy-swap
sudo mv /tmp/comfy-swap /usr/local/bin/comfy-swap
sudo chmod +x /usr/local/bin/comfy-swap
comfy-swap version
```

### macOS (Intel)

```bash
VERSION="v0.1.2"
curl -L "https://github.com/kamjin3086/comfy-swap/releases/download/$VERSION/comfy-swap-darwin-amd64" -o /tmp/comfy-swap
sudo mv /tmp/comfy-swap /usr/local/bin/comfy-swap
sudo chmod +x /usr/local/bin/comfy-swap
comfy-swap version
```

### Fallback: Build from Source (requires Go 1.21+)

```bash
git clone https://github.com/kamjin3086/comfy-swap.git /tmp/comfy-swap-src
cd /tmp/comfy-swap-src
go build -o comfy-swap .
sudo mv comfy-swap /usr/local/bin/
comfy-swap version
```

---

## Troubleshooting

### Problem: "command not found" after install

| OS | Solution |
|----|----------|
| Windows | Restart terminal, or use full path: `$env:LOCALAPPDATA\Microsoft\WindowsApps\comfy-swap.exe` |
| Linux/macOS | Check: `ls -la /usr/local/bin/comfy-swap` and `echo $PATH` |

### Problem: "connection refused"

Server not running. Start it:
```bash
comfy-swap serve -d
```

### Problem: "comfyui.reachable: false"

ComfyUI URL not configured or ComfyUI not running:
```bash
# Check current config
comfy-swap config get

# Set correct URL (ask user for their ComfyUI URL if unknown)
comfy-swap config set --comfyui-url http://localhost:8188
```

### Problem: "plugin not_installed"

```bash
# Find ComfyUI custom_nodes path (ask user if unknown)
# Common paths:
#   Windows: C:\ComfyUI\custom_nodes, D:\ComfyUI\custom_nodes
#   Linux: ~/ComfyUI/custom_nodes, /opt/ComfyUI/custom_nodes

comfy-swap install-plugin /path/to/ComfyUI/custom_nodes
# Then restart ComfyUI
```

### Problem: "no workflows found"

User needs to export workflow from ComfyUI first:
1. In ComfyUI: Right-click canvas → Export to ComfySwap
2. Then sync: `comfy-swap import --sync`

### Problem: Download blocked / network issue

Ask user to manually download from: https://github.com/kamjin3086/comfy-swap/releases

---

## Standard Workflow

After installation is verified:

```bash
# 1. Ensure server running
comfy-swap serve -d

# 2. List workflows
comfy-swap list

# 3. Check workflow parameters
comfy-swap info <workflow_id>

# 4. Run workflow
comfy-swap run <workflow_id> prompt="a cat" seed=42 --wait --save ./output/

# 5. Verify output
ls ./output/
```

## Core Commands

| Command | Purpose |
|---------|---------|
| `serve -d` | Start server as daemon |
| `stop` | Stop server |
| `health` | Check server + ComfyUI status |
| `plugin-status` | Check plugin installation |
| `install-plugin <path>` | Install ComfyUI plugin |
| `list` | List workflows |
| `info <id>` | Show workflow parameters |
| `run <id> key=value --wait --save ./` | Execute workflow |
| `import --sync` | Sync pending workflows from ComfyUI |
| `logs` | View request history |

## Parameter Format

```bash
prompt="text value"    # string
seed=42                # integer  
cfg=7.5                # float
image=@./input.png     # image file (@ prefix)
```

## When to Read Additional References

| Task | Read |
|------|------|
| Detailed setup guide | `references/setup.md` |
| Remote ComfyUI setup | `references/setup.md` (Step 3) |
| Modify workflow parameters | `references/workflow-management.md` |
| Full CLI reference | `references/cli-reference.md` |
