---
status: pending
priority: p2
issue_id: "008"
tags: [code-review, performance, architecture]
dependencies: []
---

# Admin Recalculate Action Will Timeout on Heroku

## Problem Statement
`Manage::DashboardController#recalculate` loads ALL dates ever recorded (including historical 2017-2021 data) and recalculates crowd snapshots for all of them. With thousands of dates, this will exceed Heroku's 30-second request timeout.

## Findings
- `app/controllers/manage/dashboard_controller.rb:12` — `CruiseVisit.distinct.pluck(:visit_date)` pulls every date
- The orchestrator correctly scopes to `>= today`, but the admin action doesn't
- Each date × 3 locations × 11 hours = 33 upserts. 1000 dates = 33,000 DB operations.

**Source**: architecture-strategist, kieran-rails-reviewer

## Proposed Solutions

### Option 1: Scope to future dates only (Recommended)
```ruby
def recalculate
  today = Time.use_zone("America/Virgin") { Time.zone.today }
  dates = CruiseVisit.where("visit_date >= ?", today).distinct.pluck(:visit_date).sort
  CrowdCalculationService.calculate_for_dates(dates)
  redirect_to manage_root_path, notice: "Recalculated crowd data for #{dates.size} dates."
end
```
- **Effort**: Small (5 min)
- **Risk**: None — historical snapshots are already frozen

## Acceptance Criteria
- [ ] Recalculate only processes today and future dates
- [ ] Completes within Heroku's 30-second request timeout

## Work Log
- 2026-03-28: Identified during v1 deployment review
