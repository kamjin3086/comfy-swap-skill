---
name: comfy-swap
description: Use Comfy-Swap CLI to run ComfyUI workflows, manage workflow parameters, and generate images. Trigger when user asks to run ComfyUI workflows, generate AI images, list workflows, modify workflow API parameters, inspect workflow nodes, adjust parameter mappings, check generation status, view request logs, or automate image generation tasks. Also trigger when user mentions comfy-swap, ComfyUI API, or image generation pipeline.
---

# Comfy-Swap

CLI tool for running ComfyUI workflows as stable APIs. Respond in the user's language.

## Quick Start

```bash
comfy-swap health
```

| Result | Action |
|--------|--------|
| `status: ok` | Ready — skip to [Running Workflows](#running-workflows) |
| Command not found | Run `python <skill_base>/scripts/install.py` |
| Connection refused | Run `comfy-swap serve -d` |
| `comfyui.reachable: false` | Run `comfy-swap config set --comfyui-url <url>` |

---

## Install Binary

If `comfy-swap` command not found, run:

```bash
python "<skill_base>/scripts/install.py"
```

This script:
- Auto-detects platform (Windows/Linux/macOS, amd64/arm64)
- Downloads latest release from GitHub
- Installs to user directory (no sudo required)
  - Windows: `%LOCALAPPDATA%\Microsoft\WindowsApps\`
  - Linux/macOS: `~/.local/bin/`

**Linux/macOS only:** If script reports PATH not configured, run:
```bash
echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
source ~/.bashrc
```

For specific version: `python "<skill_base>/scripts/install.py" v0.1.3`

---

## Setup Checklist

After install, verify each step:

### 1. Start Server
```bash
comfy-swap serve -d     # Start daemon (returns immediately)
comfy-swap health       # Verify: status: ok
```

### 2. Configure ComfyUI URL
```bash
comfy-swap config set --comfyui-url http://localhost:8188
comfy-swap health       # Verify: comfyui.reachable: true
```

Ask user for their ComfyUI URL if not `localhost:8188`.

### 3. Install Plugin
```bash
comfy-swap plugin-status    # Check current status
```

If `not_installed`, ask user for their ComfyUI `custom_nodes` path, then:
```bash
comfy-swap install-plugin <custom_nodes_path>
# User must restart ComfyUI after this
```

Common paths: `C:\ComfyUI\custom_nodes`, `~/ComfyUI/custom_nodes`

### 4. Import Workflows
```bash
comfy-swap list    # Check if any workflows exist
```

If empty, tell user: "In ComfyUI, right-click canvas → Export to ComfySwap"

Then sync:
```bash
comfy-swap import --sync
```

---

## Running Workflows

```bash
# List workflows
comfy-swap list

# View parameters
comfy-swap info <workflow_id>

# Run and save output
comfy-swap run <workflow_id> prompt="a cat" seed=42 --wait --save ./output/

# Verify files
ls ./output/
```

### Parameter Format
```bash
prompt="text value"    # string
seed=42                # integer  
cfg=7.5                # float
image=@./input.png     # image file (@ prefix)
```

### On Failure
```bash
comfy-swap logs --workflow <id> --limit 1
```

---

## Commands Reference

| Command | Purpose |
|---------|---------|
| `serve -d` | Start daemon |
| `stop` | Stop server |
| `health` | Check status |
| `config set --comfyui-url <url>` | Configure ComfyUI |
| `plugin-status` | Check plugin |
| `install-plugin <path>` | Install plugin |
| `list` | List workflows |
| `info <id>` | Show parameters |
| `run <id> ... --wait --save ./` | Execute workflow |
| `import --sync` | Sync from ComfyUI |
| `logs` | View history |

---

## Additional References

| Topic | File |
|-------|------|
| Detailed setup guide | `references/setup.md` |
| Full CLI reference | `references/cli-reference.md` |
| Workflow management | `references/workflow-management.md` |
