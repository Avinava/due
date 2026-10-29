---
name: ui-change
description: Add or change a screen, state or kit component in Due so it stays aligned with the design. Use for any work under packages/due_kit, app/lib/features or catalog/, and whenever a design frame (1a to 1o) changes.
---

# Changing Due's UI

The spec is `design/tokens.json`, the frame map in `design/README.md` with its goldens, and `docs/design.md`. Every change keeps four things in step: the kit component, its Widgetbook use case, the frame golden and the README screenshots.

## 1. Find the frame

Open `design/README.md` and find the frame ID (1a to 1o), its preset and its golden. Read the matching rules in `docs/design.md` (states, motion, dial geometry).

## 2. Change tokens first, if any

New or changed colours, radii, sizes or timings go in `design/tokens.json`, then `mise run gen`. Never type a hex value in a component.

## 3. Build in the kit

- One public widget per file under `packages/due_kit/lib/src/components/<role>/`.
- Take a plain view model, never an app domain type.
- Read colours from `DueTheme.of(context)` and text from `DueType`.
- Give every interactive part a semantics label, and keep tap targets at least 44px (`DueSize.tapTarget`).
- Check 200% text (`isLargeText`) and both themes.
- Export it from `lib/due_kit.dart`.
- Add or extend a widget test in `packages/due_kit/test/`.

## 4. Wire the app

- Copy and state come from a pure view model (`features/*/..._view_model.dart`); test the strings there against the design.
- Widgets in `features/` only lay out kit components.
- Apply changes to the current state, never to a copy captured by an older build.

## 5. Catalog and goldens

- Add a use case in `catalog/lib/use_cases/kit_use_cases.dart`.
- If a frame changed, update its preset in `catalog/lib/frames/frame_spec.dart`.
- Run `mise run golden`, then open the changed PNGs in `catalog/test/goldens/` and check that only the intended change moved.

## 6. Verify and refresh the README

1. `mise run gate` must pass.
2. `mise run shots` refreshes `docs/screenshots`; check the hero still reads well.
3. For layout changes, also run the app at a narrow wide width (around 800px) and at 1280px: `mise run app`.
4. Record layout decisions in `design/README.md` and behaviour rules in `docs/design.md`.
