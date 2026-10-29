#!/usr/bin/env bash
# The repo's gate: everything that must pass before a commit. Run with
# `mise run gate`.
set -euo pipefail
cd "$(dirname "$0")/.."

step() { printf '\n== %s\n' "$1"; }

step 'tokens are generated from design/tokens.json'
dart run tool/gen_tokens.dart --check

step 'format'
dart format --set-exit-if-changed --output=none .

step 'analyze'
flutter analyze

step 'app code uses kit roles, not raw style values'
if rg -n --glob '!**/*.g.dart' -e 'Color\(0x' -e '\bColors\.' -e 'fontFamily:' app/lib; then
  echo 'Raw colours or fonts in app/lib. Use DueTheme.of(context) and DueType.' >&2
  exit 1
fi

step 'kit never imports the app'
if rg -n "package:due/" packages/due_kit/lib; then
  echo 'due_kit must not depend on the app.' >&2
  exit 1
fi

step 'tests: kit'
(cd packages/due_kit && flutter test)

step 'tests: app'
(cd app && flutter test)

step 'tests: catalog goldens (frames 1a to 1o)'
(cd catalog && flutter test --exclude-tags shots)

step 'web build'
(cd app && flutter build web --release --no-web-resources-cdn >/dev/null)

printf '\nGate passed.\n'
