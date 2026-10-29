# Design notes

How Due looks and behaves, and why. The frame map and its goldens are in `design/README.md`.

## Principles

1. **Needs you leads.** The first number on screen is what the household still has to act on, not what it spends.
2. **Autopay is counted, never chased.** Mandates and cards on file add to what is committed but never to what needs you, and their rows cannot be tapped.
3. **An empty month is finished, not empty.** When nothing is left, the screen says so ("Nothing left this month.") instead of prompting for more.
4. **One accent.** Accent marks what needs action: the hero label, due marks, the Add button. Status colours appear only for real status (late, paid).
5. **Paper and ink.** Warm paper, near-black ink, hairline rules, radii of 8 or less.

## Type

| Role | Font | Used for |
|---|---|---|
| Display | Bricolage Grotesque (500 to 800) | Totals, amounts, headings, the wordmark |
| Body | Hanken Grotesk (400 to 700) | Names, schedules, copy |
| Mono | JetBrains Mono (400 to 600) | Eyebrows, dates, statuses |

All figures use tabular numerals, so a total counting down does not jitter. Amounts use Indian grouping (₹1,23,227).

## Item states

| State | Mark | Status text | Needs you |
|---|---|---|---|
| due | accent ring | "Due Thu 15", "Due today" | yes |
| late | accent fill with "!" | "2 days late" (critical) on a tinted row | yes |
| paid | ink fill with a check | "Paid" (positive), muted name | no |
| auto | dashed muted ring | "Autopay Sun 18" | no |
| settled | ruleStrong fill with a check | "Autopay · settled" | no |

Manual items before a commitment was created count as paid history, and cannot be toggled. A past month says "Settled in" only when nothing in it is still unpaid.

## The dial

The month as a ring, drawn with `CustomPainter` in a 340-unit box:

- ring at r=120, 14px stroke; the elapsed part of the month in ruleStrong
- day d at angle −90° + (d−1)·360°/n
- a tick for every day; labelled majors on 1, 8, 15, 22, 29
- today as an ink line from r=106 to r=134
- one mark per day with charges, in the day's most urgent state; late days get a halo
- the selected day gets a larger mark and an ink handle ring

Dragging anywhere on the ring selects the nearest day, with a selection haptic for each new day. The middle (under 70 of 170 units) clears the selection. The drag claims the pointer at once, so it never scrolls the list around it.

## Motion

| What | Timing |
|---|---|
| Total counting to a new value | 750ms, ease-out cubic |
| Mark colours on the dial | 400ms |
| Row background after paying | 600ms ease, highlight held 1.4s |
| Snackbar | 4.5s, with Undo for payments |

## Accessibility

- Rows are single buttons with a full label: "15 October, School fees, ₹42,000, unpaid". Long press edits.
- The dial is an adjustable control. Swiping up or down steps the day, and each mark is labelled.
- The hero is a live region, so screen readers hear the new total.
- Above 1.4× text the layout switches (frame 1g): rows become cards, the dial steps down to 230px and its third line hides. Large sizes in cards and the hero ignore further scaling, because they are already large.
- Tap targets are at least 44px.
