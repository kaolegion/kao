#!/usr/bin/env bash

gateway_provider_mistral_available() {
  [ -n "${MISTRAL_API_KEY:-}" ]
}

gateway_provider_mistral_infer() {
  local query api_url model payload response content
  query="${1:-}"

  if [ -z "${query}" ]; then
    printf 'MISTRAL_ERROR missing query\n' >&2
    return 1
  fi

  if ! gateway_provider_mistral_available; then
    printf 'MISTRAL_ERROR api key missing\n' >&2
    return 1
  fi

  api_url="${MISTRAL_API_URL:-https://api.mistral.ai/v1/chat/completions}"
  model="${MISTRAL_MODEL:-mistral-small-latest}"

  payload="$(python3 - "${model}" "${query}" <<'PY'
import json
import sys

model = sys.argv[1]
query = sys.argv[2]

print(json.dumps({
    "model": model,
    "messages": [
        {
            "role": "user",
            "content": query
        }
    ],
    "temperature": 0.2
}))
PY
)"

  response="$(curl -fsS \
    --max-time 90 \
    -H "Authorization: Bearer ${MISTRAL_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "${payload}" \
    "${api_url}")"

  content="$(python3 - "${response}" <<'PY'
import json
import sys

raw = sys.argv[1]
data = json.loads(raw)

choices = data.get("choices") or []
if not choices:
    raise SystemExit(1)

message = choices[0].get("message") or {}
content = message.get("content", "")

if isinstance(content, list):
    text_parts = []
    for item in content:
        if isinstance(item, dict) and item.get("type") == "text":
            text_parts.append(item.get("text", ""))
    content = "\n".join([p for p in text_parts if p])

print(str(content).strip())
PY
)"

  if [ -z "${content}" ]; then
    printf 'MISTRAL_ERROR empty response\n' >&2
    return 1
  fi

  printf '%s\n' "${content}"
}
