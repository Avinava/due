#!/usr/bin/env bash
# Downloads drift's web worker and sqlite3.wasm for the drift version in
# pubspec.lock into app/web. Run after upgrading drift.
set -euo pipefail
cd "$(dirname "$0")/.."

version=$(awk '/^  drift:$/{f=1} f&&/version:/{gsub(/"/,"",$2); print $2; exit}' pubspec.lock)
[ -n "$version" ] || { echo 'drift not found in pubspec.lock' >&2; exit 1; }

base="https://github.com/simolus3/drift/releases/download/drift-${version}"
for f in sqlite3.wasm drift_worker.js; do
  curl -fsSL "$base/$f" -o "app/web/$f"
done
echo "$version" > app/web/drift_version.txt
echo "Fetched drift ${version} web assets into app/web."
