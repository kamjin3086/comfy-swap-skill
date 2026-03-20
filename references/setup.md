# Comfy-Swap Setup

First-time setup and troubleshooting guide.

---

## Install Binary

If `comfy-swap` command not found:

```bash
python "<skill_base>/scripts/install.py"
```

This script auto-detects platform, downloads latest release, installs to user directory (no sudo).

**Installation paths:**
- Windows: `%LOCALAPPDATA%\Microsoft\WindowsApps\`
- Linux/macOS: `~/.local/bin/`

**Linux/macOS PATH issue:** If command still not found after install:
```bash
echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
source ~/.bashrc
```

**Specific version:** `python "<skill_base>/scripts/install.py" v0.1.3`

**Verify:** `comfy-swap version`

---

## Start Server

```bash
comfy-swap serve -d     # Start daemon (returns immediately)
comfy-swap health       # Should show status: ok
```

**Stop server:** `comfy-swap stop`

---

## Configure ComfyUI URL

```bash
comfy-swap config set --comfyui-url http://localhost:8188
comfy-swap health       # Should show comfyui.reachable: true
```

If ComfyUI runs on a different machine, ask user for the URL.

---

## Install Plugin

Check status:
```bash
comfy-swap plugin-status
```

| Status | Action |
|--------|--------|
| `connected` | Ready |
| `not_installed` | Install below |
| `not_configured` | Configure ComfyUI URL first |

### Auto-Install (AI agent runs this)

Try to find ComfyUI `custom_nodes` path and install:

```bash
comfy-swap install-plugin <custom_nodes_path>
```

**Common paths to try:**
- Windows: `C:\ComfyUI\custom_nodes`, `D:\ComfyUI\custom_nodes`
- Linux: `~/ComfyUI/custom_nodes`, `/opt/ComfyUI/custom_nodes`

If path unknown, ask user.

After install, **user must restart ComfyUI**, then verify:
```bash
comfy-swap plugin-status    # Should show: connected
```

### Manual Install (if auto-install fails)

If `install-plugin` fails or ComfyUI is on a remote machine, tell user:

> I couldn't install the plugin automatically. Please install it manually:
> 
> **Option A: Git clone (recommended)**
> ```bash
> cd /path/to/ComfyUI/custom_nodes
> git clone https://github.com/kamjin3086/ComfyUI-ComfySwap.git
> ```
> 
> **Option B: Download ZIP**
> 1. Download from: https://github.com/kamjin3086/ComfyUI-ComfySwap/archive/refs/heads/main.zip
> 2. Extract to `ComfyUI/custom_nodes/ComfyUI-ComfySwap/`
> 
> After installing, restart ComfyUI and let me know.

---

## Import Workflows

Check if workflows exist:
```bash
comfy-swap list
```

If empty, **user must export from ComfyUI manually.** Tell them:

> No workflows found. Please export a workflow from ComfyUI:
> 
> 1. Open ComfyUI in your browser (usually http://localhost:8188)
> 2. Load or create a workflow you want to use as an API
> 3. Right-click on the canvas → **Export to ComfySwap**
> 4. Configure which parameters to expose, then click **Swap**
> 5. Verify at http://localhost:8189 - the workflow should appear
> 6. **Let me know when done** so I can continue

After user confirms:
```bash
comfy-swap list    # Should now show the workflow
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `command not found` | Run install script, check PATH |
| `connection refused` | `comfy-swap serve -d` |
| `comfyui.reachable: false` | Check ComfyUI is running, verify URL |
| `plugin not_installed` | Install plugin, restart ComfyUI |
| `no workflows` | User exports from ComfyUI |
| Download fails | Check network, try manual download |
