#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "usage: $0 <repo_name> <symbol_name> [direction]" >&2
  exit 1
fi

REPO_NAME="$1"
SYMBOL_NAME="$2"
DIRECTION="${3:-upstream}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GITNEXUS_BIN="${GITNEXUS_BIN:-$SCRIPT_DIR/gitnexus-portable.sh}"

if [[ ! -x "$GITNEXUS_BIN" ]]; then
  echo "ERROR: gitnexus stable wrapper not found: $GITNEXUS_BIN" >&2
  exit 1
fi

impact_output=""
impact_status=0

set +e
impact_output="$("$GITNEXUS_BIN" impact --repo "$REPO_NAME" "$SYMBOL_NAME" 2>&1)"
impact_status=$?
set -e

if [[ $impact_status -eq 0 ]] && python3 -c 'import json, sys; data = json.load(sys.stdin); sys.exit(0 if isinstance(data, dict) and "error" not in data else 1)' <<<"$impact_output" >/dev/null 2>&1; then
  echo "$impact_output"
  exit 0
fi

echo "WARN: impact failed, falling back to context-based summary" >&2
echo "$impact_output" >&2

context_output="$("$GITNEXUS_BIN" context --repo "$REPO_NAME" "$SYMBOL_NAME" 2>&1)" || {
  echo "ERROR: context fallback failed" >&2
  exit 2
}

CONTEXT_OUTPUT="$context_output" DIRECTION="$DIRECTION" python3 <<'PY'
import json
import os
import sys

ctx = json.loads(os.environ["CONTEXT_OUTPUT"])
direction = os.environ["DIRECTION"]

incoming = ctx.get("incoming") or {}
outgoing = ctx.get("outgoing") or {}
processes = ctx.get("processes") or []
symbol = ctx.get("symbol") or {}

if direction == "upstream":
    refs = (
        (incoming.get("calls") or [])
        + (incoming.get("imports") or [])
        + (incoming.get("extends") or [])
        + (incoming.get("implements") or [])
    )
else:
    refs = (
        (outgoing.get("calls") or [])
        + (outgoing.get("imports") or [])
        + (outgoing.get("extends") or [])
        + (outgoing.get("implements") or [])
    )

ref_count = len(refs)
if ref_count >= 15:
    risk = "HIGH"
elif ref_count >= 5:
    risk = "MEDIUM"
else:
    risk = "LOW"

payload = {
    "target": {
        "id": symbol.get("uid"),
        "name": symbol.get("name"),
        "type": symbol.get("kind"),
        "filePath": symbol.get("filePath"),
    },
    "direction": direction,
    "impactedCount": ref_count,
    "risk": risk,
    "summary": {
        "direct": ref_count,
        "processes_affected": len(processes),
        "modules_affected": 0,
    },
    "affected_processes": processes,
    "affected_modules": [],
    "byDepth": {
        "1": [
            {
                "depth": 1,
                "id": ref.get("uid"),
                "name": ref.get("name"),
                "type": ref.get("kind"),
                "filePath": ref.get("filePath"),
                "relationType": "CALLS/IMPORTS",
                "confidence": 0.5,
            }
            for ref in refs
        ]
    },
    "fallbackUsed": True,
    "fallbackSource": "context",
}

json.dump(payload, sys.stdout, indent=2)
sys.stdout.write("\n")
PY
