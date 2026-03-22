#!/usr/bin/env bash
set -euo pipefail

GITNEXUS_NATIVE_BIN="${GITNEXUS_NATIVE_BIN:-$HOME/.local/bin/gitnexus-stable}"
GITNEXUS_DOCKER_IMAGE="${GITNEXUS_DOCKER_IMAGE:-node:24-trixie}"

resolve_native_path() {
  readlink -f "$GITNEXUS_NATIVE_BIN" 2>/dev/null || printf '%s\n' "$GITNEXUS_NATIVE_BIN"
}

resolve_package_root() {
  local resolved
  resolved="$(resolve_native_path)"

  if [[ -d "$resolved/node_modules" ]]; then
    printf '%s\n' "$resolved"
    return 0
  fi

  cd "$(dirname "$resolved")/../.." >/dev/null 2>&1 && pwd
}

native_runtime_ok() {
  local package_root=""
  local core_path=""

  if [[ ! -x "$GITNEXUS_NATIVE_BIN" ]]; then
    return 1
  fi

  package_root="$(resolve_package_root)" || return 1

  if [[ -d "$package_root/node_modules/@ladybugdb/core" ]]; then
    core_path="$package_root/node_modules/@ladybugdb/core"
  elif [[ -d "$(dirname "$package_root")/@ladybugdb/core" ]]; then
    core_path="$(dirname "$package_root")/@ladybugdb/core"
  fi

  if [[ -z "$core_path" ]]; then
    "$GITNEXUS_NATIVE_BIN" --version >/dev/null 2>&1
    return $?
  fi

  node -e "require('$core_path')" >/dev/null 2>&1
}

run_native() {
  exec "$GITNEXUS_NATIVE_BIN" "$@"
}

run_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    cat >&2 <<EOF
GitNexus native runtime is incompatible with this host and Docker is unavailable.

Detected binary: $GITNEXUS_NATIVE_BIN
Required fallback image: $GITNEXUS_DOCKER_IMAGE
EOF
    exit 1
  fi

  exec docker run --rm \
    --user "$(id -u):$(id -g)" \
    -e HOME="$HOME" \
    -e USER="${USER:-shimizu}" \
    -e GITNEXUS_IN_CONTAINER=1 \
    -e GITNEXUS_NATIVE_BIN="$GITNEXUS_NATIVE_BIN" \
    -v "$HOME:$HOME" \
    -v /tmp:/tmp \
    -w "$PWD" \
    "$GITNEXUS_DOCKER_IMAGE" \
    bash -lc 'exec "$GITNEXUS_NATIVE_BIN" "$@"' bash "$@"
}

main() {
  if [[ "${GITNEXUS_IN_CONTAINER:-}" == "1" ]]; then
    run_native "$@"
  fi

  if native_runtime_ok; then
    run_native "$@"
  fi

  run_docker "$@"
}

main "$@"
