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

| Result | Action |
|--------|--------|
| `status: ok` + `comfyui.reachable: true` | Ready to use |
| Command not found | Read `references/setup.md` → Install Binary |
| Connection refused | `comfy-swap serve -d` |
| `comfyui.reachable: false` | `comfy-swap config set --comfyui-url <url>` |
| Plugin `not_installed` | Read `references/setup.md` → Install Plugin |

## Upgrade

Check and upgrade to latest version. See `references/setup.md` → Upgrade section for full procedure.

---

## Running Workflows

```bash
# List available workflows
comfy-swap list

# View workflow parameters
comfy-swap info <workflow_id>

# Run workflow
comfy-swap run <workflow_id> prompt="a cat" seed=42 --wait --save ./output/
```

### Parameter Format

```bash
prompt="text value"    # string
seed=42                # integer  
cfg=7.5                # float
image=@./input.png     # image file (@ prefix)
```

### Verify Output

- Exit code 0 = success
- Check saved files: `ls ./output/`
- On failure: `comfy-swap logs --workflow <id> --limit 1`

---

## Common Tasks

### Generate Image with Custom Parameters
```bash
comfy-swap run <id> prompt="portrait of a woman" negative_prompt="blurry" seed=42 steps=30 --wait --save ./
```

### Check Workflow Available Parameters
```bash
comfy-swap info <workflow_id>
```

### View Recent Execution History
```bash
comfy-swap logs --limit 5
```

### Modify Workflow Parameters (add/remove/update)
```bash
comfy-swap workflow params <id>                    # View current params
comfy-swap workflow add-param <id> --name steps --type integer --node 3 --field steps --default 20
comfy-swap workflow update-param <id> --name seed --default 42
comfy-swap workflow remove-param <id> --name unwanted
```

---

## Commands Quick Reference

| Command | Purpose |
|---------|---------|
| `health` | Check status |
| `list` | List workflows |
| `info <id>` | Show workflow parameters |
| `run <id> key=value --wait --save ./` | Execute workflow |
| `logs` | View execution history |
| `workflow params <id>` | View/manage parameters |
| `serve -d` / `stop` | Start/stop server |

---

## References

| When | Read |
|------|------|
| First-time setup, install issues | `references/setup.md` |
| Upgrade to latest version | `references/setup.md` → Upgrade |
| Full CLI commands | `references/cli-reference.md` |
| Advanced workflow management | `references/workflow-management.md` |
