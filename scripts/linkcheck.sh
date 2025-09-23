#!/usr/bin/env bash
set -euo pipefail

# Simple repo-wide markdown link checker using markdown-link-check
# Usage: ./scripts/linkcheck.sh

command -v markdown-link-check >/dev/null 2>&1 || {
  echo "markdown-link-check is not installed. Install with: npm i -g markdown-link-check" >&2
  exit 2
}

FAILED=0

# Find all markdown files (exclude vendor/.git, node_modules)
IFS=$'\n'
for file in $(git ls-files "*.md"); do
  echo "Checking $file"
  markdown-link-check -q "$file" || FAILED=1
done

if [ "$FAILED" -ne 0 ]; then
  echo "One or more Markdown link checks failed." >&2
  exit 1
fi

echo "All markdown link checks passed."