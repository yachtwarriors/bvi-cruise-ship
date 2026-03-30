---
status: pending
priority: p1
issue_id: "004"
tags: [code-review, bug, security]
dependencies: []
---

# `start_date` Param Crashes on Invalid Input

## Problem Statement
`PagesController#home` line 6: `params[:start_date]&.to_date` raises `Date::Error` on malformed input (e.g., `?start_date=garbage`), returning a 500 error to the user. This is the public homepage.

## Findings
- `app/controllers/pages_controller.rb:6` — no rescue around `.to_date`
- Additionally, extreme dates like `?start_date=1900-01-01` will run valid but unnecessary DB queries.

**Source**: kieran-rails-reviewer, security-sentinel

## Proposed Solutions

### Option 1: Rescue and fallback to today (Recommended)
```ruby
@start_date = begin
  params[:start_date]&.to_date || @today
rescue Date::Error
  @today
end
```
- **Effort**: Small (5 min)
- **Risk**: None

## Acceptance Criteria
- [ ] `?start_date=garbage` shows today's schedule, not a 500
- [ ] `?start_date=2026-04-01` works normally

## Work Log
- 2026-03-28: Identified during v1 deployment review
