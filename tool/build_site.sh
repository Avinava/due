#!/usr/bin/env bash
# Builds the web demo and the design kit into build/site for GitHub Pages:
# the app at $BASE and the kit at ${BASE}kit/. BASE defaults to "/"; use
# BASE=/due/ for a project site.
set -euo pipefail
cd "$(dirname "$0")/.."
base="${BASE:-/}"
out=build/site

rm -rf "$out"
(cd app && flutter build web --release --no-web-resources-cdn --base-href "$base")
(cd catalog && flutter build web --release --no-web-resources-cdn --base-href "${base}kit/")
mkdir -p "$out"
cp -R app/build/web/. "$out/"
cp -R catalog/build/web "$out/kit"
touch "$out/.nojekyll"
echo "Built $out (app at $base, kit at ${base}kit/)."
