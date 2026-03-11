---
name: load-agents-via-robobird-api
description: Load (bulk upsert) AI agents and prompts into Robobird through HTTP API endpoints /api/agents/load and /api/agents.
---

# Load Agents via Robobird API

## Cel
Ujednolicony workflow dla Codexa i Claude Code do ladowania paczki agentow przez API Robobird.

## Wymagane zmienne
```bash
export ROBOBIRD_API_URL="http://127.0.0.1:3001"
```

## Input
Skrypt akceptuje dwa formaty JSON:
1. API-native:
```json
{
  "agents": [
    {
      "id": "agent-id",
      "name": "Agent Name",
      "description": "...",
      "role": "...",
      "enabled": true,
      "prompts": [
        {"title": "Main", "content": "...", "order_index": 0}
      ]
    }
  ]
}
```

2. Use-case format (`robobird/.use-case/output/it-10-agents-10-requests.json`) gdzie agent ma pola `promptTitle` + `promptContent`.

## Uzycie
```bash
# 1) Podglad payload (bez POST)
./scripts/load_agents_via_api.sh --source /path/file.json --dry-run

# 2) Zaladowanie agentow
./scripts/load_agents_via_api.sh \
  --url "$ROBOBIRD_API_URL" \
  --source /path/file.json

# 3) Nie usuwaj starych promptow agenta
./scripts/load_agents_via_api.sh \
  --url "$ROBOBIRD_API_URL" \
  --source /path/file.json \
  --replace-prompts false
```

## Weryfikacja
```bash
curl -sS "$ROBOBIRD_API_URL/api/agents" | jq '.data | length'
```

## Odpowiedz API
`POST /api/agents/load` zwraca:
- `agents_loaded`
- `prompts_loaded`

## Failure handling
- `400`: bledny JSON, brak `id` lub `name`, puste prompty.
- `500`: problem DB po stronie aplikacji.
- `000` (curl): API niedostepne; sprawdz, czy app dziala na porcie 3001.
