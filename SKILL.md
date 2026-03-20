---
name: comfy-swap
description: Use Comfy-Swap CLI to run ComfyUI workflows, manage workflow parameters, and generate images. Trigger when user asks to run ComfyUI workflows, generate AI images, list workflows, modify workflow API parameters, inspect workflow nodes, adjust parameter mappings, check generation status, view request logs, or automate image generation tasks. Also trigger when user mentions comfy-swap, ComfyUI API, or image generation pipeline.
---

# Comfy-Swap

CLI tool for running ComfyUI workflows as stable APIs. Respond in the user's language.

**Skill base directory:** Use this path to resolve script references below.

---

## Step 1: Check Status

Run the check script first to diagnose the current state:

**Windows:**
```powershell
powershell -ExecutionPolicy Bypass -File "<skill_base>/scripts/check.ps1"
```

**Linux/macOS:**
```bash
bash "<skill_base>/scripts/check.sh"
```

The script returns JSON with `issues` and `actions` arrays. If `issues` is empty, skip to [Running Workflows](#running-workflows).

---

## Step 2: Fix Issues

### Issue: "comfy-swap binary not installed"

Run the install script (auto-detects platform, downloads latest, installs to PATH):

**Windows:**
```powershell
powershell -ExecutionPolicy Bypass -File "<skill_base>/scripts/install.ps1"
```

**Linux/macOS:**
```bash
bash "<skill_base>/scripts/install.sh"
```

### Issue: "Server not running"

```bash
comfy-swap serve -d
```

### Issue: "ComfyUI not reachable"

Ask user for their ComfyUI URL, then:
```bash
comfy-swap config set --comfyui-url <user_provided_url>
```

Common URLs: `http://localhost:8188`, `http://127.0.0.1:8188`

### Issue: "ComfyUI plugin not installed"

Ask user for their ComfyUI `custom_nodes` path, then:
```bash
comfy-swap install-plugin <custom_nodes_path>
```

Common paths:
- Windows: `C:\ComfyUI\custom_nodes`, `D:\ComfyUI\custom_nodes`
- Linux: `~/ComfyUI/custom_nodes`, `/opt/ComfyUI/custom_nodes`

After installing, user must restart ComfyUI.

### Issue: "No workflows found"

User needs to export a workflow from ComfyUI first:
1. Tell user: "In ComfyUI, right-click canvas → Export to ComfySwap"
2. After user exports, run: `comfy-swap import --sync`

---

## Quick Setup (All-in-One)

If starting fresh, run the setup script which handles install + server + config:

**Windows:**
```powershell
powershell -ExecutionPolicy Bypass -File "<skill_base>/scripts/setup.ps1" -ComfyUIUrl "http://localhost:8188"
```

**Linux/macOS:**
```bash
bash "<skill_base>/scripts/setup.sh" "http://localhost:8188"
```

---

## Running Workflows

Once check script shows no issues:

```bash
# List available workflows
comfy-swap list

# View workflow parameters
comfy-swap info <workflow_id>

# Run workflow and save output
comfy-swap run <workflow_id> prompt="a cat" seed=42 --wait --save ./output/

# Verify output files exist
ls ./output/
```

### Parameter Format

```bash
prompt="text value"    # string
seed=42                # integer  
cfg=7.5                # float
image=@./input.png     # image file (@ prefix)
```

### After Run Completes

- Exit code 0 → success
- Output JSON includes `prompt_id`, `status`, `files`
- On failure: `comfy-swap logs --workflow <id> --limit 1`

---

## Core Commands

| Command | Purpose |
|---------|---------|
| `serve -d` | Start server as daemon |
| `stop` | Stop server |
| `health` | Check status |
| `list` | List workflows |
| `info <id>` | Show parameters |
| `run <id> key=value --wait --save ./` | Execute |
| `import --sync` | Sync from ComfyUI |
| `install-plugin <path>` | Install plugin |
| `logs` | View history |

---

## Scripts Reference

| Script | Purpose |
|--------|---------|
| `scripts/check.ps1` / `check.sh` | Diagnose status, return issues and actions |
| `scripts/install.ps1` / `install.sh` | Install or upgrade binary |
| `scripts/setup.ps1` / `setup.sh` | Complete setup (install + server + config) |

---

## Additional References

| Task | Read |
|------|------|
| Detailed setup | `references/setup.md` |
| Remote ComfyUI | `references/setup.md` (Step 3) |
| Workflow management | `references/workflow-management.md` |
| Full CLI reference | `references/cli-reference.md` |
