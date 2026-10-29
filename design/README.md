# Design

Due's design is specified by three things in this repo:

- `tokens.json`: the single source for colours, radii, sizes, motion and fonts. `mise run gen` writes `packages/due_kit/lib/src/foundation/tokens.g.dart` and `app/ios/DueWidget/DueTokens.g.swift` from it.
- The frames 1a to 1o below, each rendered from the real app as a golden in `catalog/test/goldens/`. A golden changes only when the design does.
- `docs/design.md`: principles, item states, motion, dial geometry and accessibility.

## Frame map

Every frame has a fixture in `catalog/lib/frames/frame_spec.dart`, a golden in `catalog/test/goldens/` and a screenshot in `docs/screenshots/`. All use the sample household with today at Mon 12 Oct 2026.

| Frame | Name | Preset | Golden |
|---|---|---|---|
| 1a | Month | default | `1a_month_light.png` |
| 1b | Day scrubbed | day 15 selected | `1b_day_scrubbed_light.png` |
| 1c | Marked paid | school fees just paid, snackbar, −₹42,000 | `1c_marked_paid_light.png` |
| 1d | Nothing left | society, school and LIC also paid | `1d_nothing_left_light.png` |
| 1e | Edit sheet | credit card bill, ₹12,000, the 31st, from Dec 2026 | `1e_edit_sheet_light.png` |
| 1f | Settings | reminders on at 9:00 AM | `1f_settings_light.png` |
| 1g | 200% text | text scale 2 | `1g_200_text_light.png` |
| 1h | Month, dark | default | `1h_month_dark.png` |
| 1i | Marked paid, dark | as 1c | `1i_marked_paid_dark.png` |
| 1j | Edit sheet, dark | as 1e | `1j_edit_sheet_dark.png` |
| 1k | Settings, dark | as 1f | `1k_settings_dark.png` |
| 1l | Wide | 1280×800 | `1l_wide_light.png` |
| 1m | Wide, dark | 1280×800 | `1m_wide_dark.png` |
| 1n | Widgets | small and medium | `1n_small_widget_light.png`, `1n_medium_widget_light.png` |
| 1o | Widgets, dark | small and medium | `1o_small_widget_dark.png`, `1o_medium_widget_dark.png` |

## Layout notes

- **Wide layout from 720px.** At 1280px the dial pane is 560px. Narrower, it takes 44% of the width (at least 380px), rows stack like phone rows below 560px, and the top bar shortens to "+ Add".
- **Month arrows** are drawn chevrons, not text characters, so they keep their size in every font.
- **Settings in the frames** shows Light or Dark selected rather than System, because the catalog forces the theme per frame.
- **Rows** can be long-pressed (or right-clicked) to edit or archive.
- **The ₹ glyph** only exists in Bricolage Grotesque, so body and mono text fall back to it for that one character.
