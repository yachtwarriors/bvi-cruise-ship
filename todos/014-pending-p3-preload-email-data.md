---
status: pending
priority: p3
issue_id: "014"
tags: [code-review, performance]
dependencies: []
---

# Pre-load Shared Data in Email Rake Task

## Problem Statement
Each email triggers 3 DB queries (visits, locations, snapshots) independently, even though every user gets the same date's data. With N users, that's N x 3 redundant queries.

## Findings
- `lib/tasks/email.rake:23` — `DailyCrowdAlertMailer.daily_alert(user, date).deliver_now` inside `find_each`
- `app/mailers/daily_crowd_alert_mailer.rb:5-11` — loads visits, locations, snapshots per call

**Source**: performance-oracle

## Proposed Solutions

### Option 1: Pre-load data once, pass to mailer
Load visits/locations/snapshots before the user loop, pass as an argument.
- **Effort**: Small (20 min)
- **Risk**: Low — need to update mailer method signature

## Acceptance Criteria
- [ ] Shared data loaded once, not per-user

## Work Log
- 2026-03-28: Identified during v1 deployment review
