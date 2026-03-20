# Comfy-Swap Skill

[![skills.sh](https://img.shields.io/badge/skills.sh-comfy--swap-blue)](https://skills.sh/kamjin3086/comfy-swap-skill)

AI agent skill for running ComfyUI workflows via CLI and REST API.

## Installation

```bash
npx skills add kamjin3086/comfy-swap-skill
```

## What This Skill Does

Enables AI agents to:
- Run ComfyUI image generation workflows programmatically
- Manage workflow parameters (add, remove, update)
- Install and configure the ComfyUI plugin
- View execution logs and results

## Prerequisites

This skill requires the `comfy-swap` CLI tool:

1. Download from [comfy-swap releases](https://github.com/kamjin3086/comfy-swap/releases)
2. Add to PATH
3. Run `comfy-swap serve` to start the API server

## Quick Start

After installing the skill, AI agents will automatically:

1. Check if `comfy-swap` is installed and running
2. Guide you through setup if needed
3. Execute workflows on your behalf

## Links

- [Comfy-Swap Repository](https://github.com/kamjin3086/comfy-swap)
- [ComfyUI Plugin](https://github.com/kamjin3086/ComfyUI-ComfySwap)

## License

MIT
