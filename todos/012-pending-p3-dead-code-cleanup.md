---
status: pending
priority: p3
issue_id: "012"
tags: [code-review, quality, cleanup]
dependencies: []
---

# Dead Code Cleanup

## Problem Statement
Several unused methods, scopes, and constants across the codebase. Not harmful but adds cognitive load.

## Findings
- `ShipCapacityLookup.median_capacity` — never called
- `PagesHelper#contributing_port?` — never called in any view
- `PagesHelper#ships_summary` — never called in any view
- `ScrapeLog.last_successful` (parameterless) — never called, only `last_successful_for(source)` is used
- `CruiseVisit.at_port` scope — never used
- `Location.by_slug` and `Port.by_slug` scopes — never used
- `daily_alert.html.erb:43` — `best_time_text` method call guarded by `respond_to?` but never defined; `best_time` variable never used

**Source**: code-simplicity-reviewer

## Proposed Solutions

### Option 1: Delete all dead code
Remove all unused methods/scopes listed above. ~30 lines total.
- **Effort**: Small (15 min)
- **Risk**: None

## Acceptance Criteria
- [ ] All listed dead code is removed
- [ ] App still boots and functions correctly

## Work Log
- 2026-03-28: Identified during v1 deployment review
