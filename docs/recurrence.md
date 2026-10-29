# Recurrence rules

Code: `app/lib/domain/cadence.dart` and `recurrence.dart`. Tests: `app/test/domain/recurrence_test.dart`.

Every date is a UTC calendar date. A cadence answers one question: which days in a given month does it fall on? `upcoming` builds on that question to give the next dates.

## Cadences

| Cadence | Example | Rule |
|---|---|---|
| `Monthly(day)` | Rent on the 1st | Every month on `day`. |
| `Monthly(day, from, count)` | Car EMI, 36 payments | Starts in `from`, numbered 1 onwards, stops after `count`. Shown as "EMI 14 of 36". |
| `EveryNMonths(n, from, day)` | Society maintenance (3), LIC (12) | Every `n` months starting in `from`, on `day`. 3, 6 and 12 read as Quarterly, Half-yearly and Yearly. |
| `EveryNMonths(n, from, day, terms)` | School fees, 3 terms | As above, labelled "Term i of terms", wrapping each year. |
| `Weekly(weekday, from)` | A weekly class | Every `weekday` on or after `from`. |
| `EveryNDays(n, anchor)` | Jio, every 28 days | Steps of `n` days from `anchor`, ignoring months. A 28-day plan drifts through the calendar and can fall twice in one month. |

## Short months

A day that a month doesn't have falls on that month's last day, and the occurrence records the day it was moved from (`clampedFrom`). The cadence keeps its own day, so the next month goes back to it:

| Rule | Dates |
|---|---|
| Monthly on the 31st, from December 2026 | 31 Dec, 31 Jan, **28 Feb** (clamped from 31st), 31 Mar |
| Quarterly on the 31st, from February 2027 | **28 Feb**, 31 May, 31 Aug |
| Yearly on 29 Feb 2028 | 29 Feb 2028, **28 Feb 2029, 2030, 2031**, 29 Feb 2032 |

The edit sheet shows the next three dates and flags any clamp before the user saves (frame 1e).

## States

For a given today:

- An autopay item is `auto` until its date, then `settled`.
- A manual item is `paid` if it is marked paid or falls before the commitment was created. Otherwise it is `due` from today on, and `late` before today.
- Needs you is the sum of `due` and `late`.

## Reminders

A manual item that is `due` after today and within 60 days gets a notification at the chosen hour on the day before, unless that time has already passed. The plan is capped at 64, because iOS keeps no more than that pending. Notification ids are stable per occurrence, so rescheduling replaces rather than duplicates.
