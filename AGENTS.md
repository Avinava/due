# AGENTS.md

Instructions for coding agents (and people) working in this repo. `CLAUDE.md` imports this file; edit this one.

## What this is

Due is a local-first Flutter app for iOS, macOS and web. It shows what a household has committed to pay this month and what still needs them. It is a portfolio piece: the code, the design kit and the README are read as closely as the app is used.

## Layout

```
app/                  the app (package `due`)
  lib/domain/         pure Dart: calendar, money, cadence, recurrence, month brief, reminder plan
  lib/data/           repository interface, drift and in-memory implementations, backup format, sample household
  lib/features/       month/, edit/, settings/, home_widget/  (view models are pure; widgets only lay out)
  lib/platform/       reminders, home-screen widget, backup files: each an interface plus a no-op
  lib/app/            providers, router, app shell, snackbar host
  ios/DueWidget/      the WidgetKit extension (SwiftUI)
packages/due_kit/     the design kit: foundation/ (tokens, theme, type) and components/ by role
catalog/              Widgetbook catalog, the 1a to 1o frame fixtures, goldens and README screenshots
design/               tokens.json (source of truth) and the frame map
docs/                 design, architecture, recurrence, screenshots, media
tool/                 gate, token generator, web assets, site build, iOS target script
```

## Commands

All tools come from mise (`mise install`). Run from the repo root.

| Command | What it does |
|---|---|
| `mise run gate` | Everything that must pass before a commit |
| `mise run gen` | Regenerate Dart and Swift tokens from `design/tokens.json` |
| `mise run golden` | Re-render the frame goldens after an intended UI change |
| `mise run shots` | Re-render `docs/screenshots` (README images, hero, social preview) |
| `mise run kit` | Open the catalog in Chrome |
| `mise run app` | Run the app on macOS |
| `mise run web` | Build the app and catalog into `build/site` |

This is a pub workspace with one lockfile at the root. Add dependencies with `flutter pub add` inside the package that needs them.

## Rules

- **Design is the source of truth.** Every screen maps to a frame (1a to 1o) in `design/README.md`, pinned by a golden. Follow the `ui-change` skill (`.claude/skills/ui-change/SKILL.md`) for any UI work.
- **Tokens.** Colours, radii, sizes and motion live in `design/tokens.json`. Never hand-edit `*.g.dart` or `DueTokens.g.swift`; run `mise run gen`.
- **No raw style in the app.** `app/lib` uses `DueTheme.of(context)` and `DueType`, never `Color(0x...)`, `Colors.` or `fontFamily:`. The gate enforces this.
- **The kit stands alone.** `packages/due_kit` never imports `package:due`. Components take plain view models (`RowModel`, `DialModel`), not domain types.
- **One public widget per kit file**, in the folder for its role (`buttons`, `display`, `feedback`, `inputs`, `layout`, `month`). Export it from `lib/due_kit.dart`, give it a widget test and a Widgetbook use case.
- **Domain first.** Date and money logic is pure Dart in `app/lib/domain` with table-driven tests. Recurrence changes update `docs/recurrence.md`.
- **Fixed clock.** Tests, goldens and the catalog use 12 Oct 2026 through `clockProvider`. The acceptance numbers are ₹73,680 needs you, ₹1,23,227 committed, ₹15,547 on autopay.
- **Platform seams are interfaces.** Reminders, home widgets and backup files are overridden with fakes in tests. Do not call plugins from features.
- **State changes go through the current value.** Never build a new form or state from a copy captured at build time; apply a transform to the current one (see `EditSheet._apply`).
- **Fonts ship in the kit.** Styles must set `package: 'due_kit'` (`DueType` does). Only Bricolage Grotesque has the ₹ glyph; the other roles fall back to it.

## Git and writing

- Branch before committing; never commit to `main` directly. Never use `--no-verify`.
- Short commit messages. No co-author or tool attribution lines.
- Run the `privacy-scan` skill before any push, tag or Pages deploy.
- Writing: no em dashes, straight quotes, prices in INR with Indian grouping.

## Known gaps

- iOS builds need the iOS platform installed in Xcode (Settings > Components). The widget extension is added by `tool/ios/add_widget_target.rb`.
- Goldens are rendered on macOS; CI runs on a macOS runner so pixels match.
