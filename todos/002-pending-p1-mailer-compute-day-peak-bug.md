---
status: pending
priority: p1
issue_id: "002"
tags: [code-review, bug, mailer]
dependencies: []
---

# `return` vs `next` Bug in DailyCrowdAlertMailer#compute_day_peak

## Problem Statement
`compute_day_peak` uses `return "green"` inside a `map` block. This exits the entire method on the first location with no snapshots, ignoring remaining locations. Daily alert emails could report "green" when the day is actually red/yellow.

## Findings
- `app/mailers/daily_crowd_alert_mailer.rb:28` — `return "green"` should be `next "green"`
- The mailer already includes `PagesHelper` which has `day_peak_intensity` doing the same logic correctly. The private `compute_day_peak` is a duplicate with a bug.

**Source**: kieran-rails-reviewer, code-simplicity-reviewer, architecture-strategist

## Proposed Solutions

### Option 1: Fix `return` to `next` (Quick fix)
Change line 28 from `return "green"` to `next "green"`.
- **Effort**: Small (2 min)
- **Risk**: None

### Option 2: Delete `compute_day_peak` and use `day_peak_intensity` from PagesHelper (Better)
The mailer already has `helper PagesHelper`. Replace `compute_day_peak` with a call to `day_peak_intensity(@date, @locations, @snapshots_by_loc_id)` — adjusting the snapshots grouping to match.
- **Effort**: Small (10 min)
- **Risk**: Low — need to verify snapshot grouping keys match

## Acceptance Criteria
- [ ] `compute_day_peak` returns correct peak across all locations, not just the first
- [ ] Email shows correct CTA (Yacht Warriors only on yellow/red days)

## Work Log
- 2026-03-28: Identified during v1 deployment review
