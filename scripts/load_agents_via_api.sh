#!/usr/bin/env bash
set -euo pipefail

URL="${ROBOBIRD_API_URL:-http://127.0.0.1:3001}"
SOURCE=""
REPLACE_PROMPTS="true"
DRY_RUN="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url) URL="$2"; shift 2 ;;
    --source) SOURCE="$2"; shift 2 ;;
    --replace-prompts) REPLACE_PROMPTS="$2"; shift 2 ;;
    --dry-run) DRY_RUN="true"; shift 1 ;;
    --help|-h)
      cat <<USAGE
Usage:
  load_agents_via_api.sh --source <json-file> [--url <api-url>] [--replace-prompts true|false] [--dry-run]
USAGE
      exit 0
      ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

[[ -n "$SOURCE" ]] || { echo "Missing --source" >&2; exit 2; }
[[ -f "$SOURCE" ]] || { echo "Source file not found: $SOURCE" >&2; exit 2; }
[[ "$REPLACE_PROMPTS" == "true" || "$REPLACE_PROMPTS" == "false" ]] || {
  echo "--replace-prompts must be true or false" >&2
  exit 2
}

payload="$(jq -c --argjson replace "$REPLACE_PROMPTS" '
  def prompt_obj:
    ({
      title: .title,
      content: .content,
      order_index: (.order_index // 0)
    } + (if ((.id // "") | length) > 0 then {id: .id} else {} end));

  def to_agent:
    {
      id: .id,
      name: .name,
      description: (.description // ""),
      role: (.role // "Asystent"),
      enabled: (.enabled // true),
      prompts:
        (if (.prompts | type) == "array" then
          [.prompts[] | prompt_obj]
        elif ((.promptTitle // "") | length) > 0 and ((.promptContent // "") | length) > 0 then
          [{
            id: ((.id // "agent") + "-prompt-main"),
            title: .promptTitle,
            content: .promptContent,
            order_index: 0
          }]
        else
          []
        end)
    };

  {
    agents:
      (if (type == "object" and (.agents | type) == "array") then
        [.agents[] | to_agent]
      elif type == "array" then
        [.[] | to_agent]
      else
        error("Unsupported source format")
      end),
    replace_existing_prompts: $replace
  }
' "$SOURCE")"

if [[ "$DRY_RUN" == "true" ]]; then
  echo "$payload" | jq
  exit 0
fi

curl -sS -X POST "$URL/api/agents/load" \
  -H 'Content-Type: application/json' \
  --data-binary "$payload" | jq
