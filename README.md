# robobird-skills

Robobird skill pack — reusable skills and scripts for managing Robobird agents and releases.

## Skills

### [load-agents-via-robobird-api](skills/load-agents-via-robobird-api.SKILL.md)
Bulk upsert AI agents and prompts into Robobird via HTTP API (`/api/agents/load`).

```bash
./scripts/load_agents_via_api.sh --url "$ROBOBIRD_API_URL" --source /path/file.json
```

### [release-robobird-to-robobird-app](skills/release-robobird-to-robobird-app.SKILL.md)
End-to-end release workflow: production Tauri build, binary publish to robobird.app, version update, and remote deploy.

## Scripts

- `scripts/load_agents_via_api.sh` — API loader for agents/prompts

## Requirements

```bash
export ROBOBIRD_API_URL="http://127.0.0.1:3001"
```
