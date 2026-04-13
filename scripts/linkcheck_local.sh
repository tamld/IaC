#!/usr/bin/env bash
set -euo pipefail
trap 'echo "[ERR] at line $LINENO" >&2' ERR

# Local link-check script using markdown-link-check via npx (no global install required).
# Scans all tracked Markdown files and returns non-zero if any file has failing links.

failures=0

# Patterns to skip (adjust if needed)
SKIP_PATTERNS=("vendor/" ".git/" "node_modules/" "docs/archive/")

should_skip() {
  local path="$1"
  for p in "${SKIP_PATTERNS[@]}"; do
    if [[ "$path" == *"$p"* ]]; then
      return 0
    fi
  done
  return 1
}

# Use the repository config file .markdown-link-check.json if present
CONFIG_FILE=".markdown-link-check.json"

# Iterate tracked Markdown files
git ls-files '*.md' | while IFS= read -r md; do
  if should_skip "$md"; then
    echo "Skipping $md"
    continue
  fi

  echo "Checking $md"
  if [[ -f "$CONFIG_FILE" ]]; then
    if ! npx --yes markdown-link-check -c "$CONFIG_FILE" "$md"; then
      echo "FAILED: $md"
      failures=$((failures+1))
    fi
  else
    if ! npx --yes markdown-link-check "$md"; then
      echo "FAILED: $md"
      failures=$((failures+1))
    fi
  fi
done

if [ "$failures" -ne 0 ]; then
  echo "Link check found $failures file(s) with failing links."
  exit 2
fi

echo "All markdown link checks passed."
exit 0
