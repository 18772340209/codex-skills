#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="$REPO_ROOT/skills"
CODEX_ROOT="${CODEX_HOME:-$HOME/.codex}"
TARGET="$CODEX_ROOT/skills"

mkdir -p "$TARGET"

for dir in "$SOURCE"/*; do
  [ -d "$dir" ] || continue
  name="$(basename "$dir")"
  rm -rf "$TARGET/$name"
  cp -R "$dir" "$TARGET/$name"
  echo "Installed $name -> $TARGET/$name"
done

echo "Done. Reload/restart Codex if needed."
