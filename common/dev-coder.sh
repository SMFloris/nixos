#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="$HOME/.config/opencode/dev.json"

set_config() {
  mkdir -p "$(dirname "$CONFIG_FILE")"
  read -rp "Enter absolute path to project root: " ROOT_DIR
  echo "{\"root_dir\": \"$ROOT_DIR\"}" > "$CONFIG_FILE"
  echo "Saved root_dir to $CONFIG_FILE"
}

# Handle --config option
if [[ "${1:-}" == "--config" ]]; then
  set_config
  exit 0
fi

# Load or create config
if [[ ! -f "$CONFIG_FILE" ]]; then
  set_config
fi
ROOT_DIR="$(jq -r '.root_dir' "$CONFIG_FILE")"

# Require a working dir argument
WORKDIR="${1:?Please provide a directory to cd into}"
shift

cd "$WORKDIR" || exit 1
exec bun run --conditions=development "$ROOT_DIR/packages/opencode/src/index.ts" "$@"
