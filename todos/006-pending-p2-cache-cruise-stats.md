---
status: pending
priority: p2
issue_id: "006"
tags: [code-review, performance]
dependencies: []
---

# Cache `build_cruise_stats` — 4 Unnecessary DB Queries Per Page Load

## Problem Statement
`PagesController#build_cruise_stats` fires 4 separate aggregate queries on every homepage request. These rolling stats change once per day (at scrape time) but every visitor pays for all 4 queries.

## Findings
- `app/controllers/pages_controller.rb:32-48` — 4 `window_stats` calls, each doing COUNT + SUM
- Year-over-year queries (`last_7_ly`, `last_30_ly`) return zero until the app has 13+ months of data — wasted work right now

**Source**: performance-oracle, architecture-strategist

## Proposed Solutions

### Option 1: Rails.cache.fetch with daily expiry (Recommended)
```ruby
def build_cruise_stats
  Rails.cache.fetch("cruise_stats/#{@today}", expires_in: 1.hour) do
    # existing code
  end
end
```
- **Effort**: Small (5 min)
- **Risk**: None — data only changes at scrape time

## Acceptance Criteria
- [ ] Rolling stats are cached and not re-queried on every page load
- [ ] Cache invalidates at least daily

## Work Log
- 2026-03-28: Identified during v1 deployment review
