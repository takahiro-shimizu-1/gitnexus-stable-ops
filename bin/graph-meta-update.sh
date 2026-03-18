#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GITNEXUS_BIN="${GITNEXUS_BIN:-$HOME/.local/bin/gitnexus-stable}"
OUTPUT_DIR="${OUTPUT_DIR:-$PWD/out}"
OUTPUT_FILE="${OUTPUT_FILE:-$OUTPUT_DIR/graph-meta.jsonl}"
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
LOG="${LOG:-/tmp/graph-meta-update.log}"
PARSE_SCRIPT="$SCRIPT_DIR/../lib/parse_graph_meta.py"

_cleanup() {
  rm -f "${TMP:-}"
}
trap _cleanup EXIT

echo "=== Graph Meta Update $TS ===" > "$LOG"

if [[ ! -x "$GITNEXUS_BIN" ]]; then
  echo "ERROR: gitnexus binary not found: $GITNEXUS_BIN" >> "$LOG"
  cat "$LOG"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

REPOS=$("$GITNEXUS_BIN" list 2>/dev/null | grep -E '^  [A-Za-z]' | sed 's/^  //' | grep -v '^Indexed' || true)
if [[ -z "$REPOS" ]]; then
  echo "No indexed repos found" >> "$LOG"
  cat "$LOG"
  exit 0
fi

if [[ ! -f "$PARSE_SCRIPT" ]]; then
  echo "ERROR: parse_graph_meta.py not found: $PARSE_SCRIPT" >> "$LOG"
  cat "$LOG"
  exit 1
fi

QUERY="MATCH (a)-[r:CodeRelation]->(b), (c1:Community)-[:CodeRelation]->(a), (c2:Community)-[:CodeRelation]->(b) WHERE c1 <> c2 RETURN c1.label AS from_cluster, c1.symbolCount AS from_size, c2.label AS to_cluster, c2.symbolCount AS to_size, count(r) AS cross_edges ORDER BY cross_edges DESC LIMIT 50"
TMP=$(mktemp)

while IFS= read -r repo; do
  [[ -z "$repo" ]] && continue
  RESULT=$("$GITNEXUS_BIN" cypher --repo "$repo" "$QUERY" 2>&1) || true
  if [[ -z "$RESULT" ]]; then
    continue
  fi
  echo "$RESULT" | python3 "$PARSE_SCRIPT" "$repo" "$TS" >> "$TMP" 2>/dev/null || true
done <<< "$REPOS"

if [[ -s "$TMP" ]]; then
  mv "$TMP" "$OUTPUT_FILE"
  echo "Updated $OUTPUT_FILE" >> "$LOG"
else
  rm -f "$TMP"
  echo "No data generated" >> "$LOG"
fi

cat "$LOG"
