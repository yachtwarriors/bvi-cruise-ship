---
status: pending
priority: p2
issue_id: "007"
tags: [code-review, performance]
dependencies: []
---

# Cache AppConfig Reads — Hundreds of Redundant DB Queries Per Scrape

## Problem Statement
`AppConfig.get` fires a fresh DB query on every call. `CrowdCalculationService` calls it ~15 times per location per date inside nested loops. A scrape covering 60 future dates generates hundreds of identical SELECT queries for the same ~8 config keys.

## Findings
- `app/models/app_config.rb:6` — `find_by(key: key)` on every call
- `app/services/crowd_calculation_service.rb` — `AppConfig.get_float` / `get_int` called in `find_contributing_visits` and `transit_time_for` inside hot loops

**Source**: performance-oracle, kieran-rails-reviewer, architecture-strategist

## Proposed Solutions

### Option 1: In-memory class-level cache (Recommended)
```ruby
def self.get(key, default: nil)
  all_cached[key] || default
end

def self.all_cached
  @all_cached ||= pluck(:key, :value).to_h
end

def self.reload_cache!
  @all_cached = nil
end
```
Call `reload_cache!` after admin config updates.
- **Effort**: Small (15 min)
- **Risk**: None — values almost never change

## Acceptance Criteria
- [ ] AppConfig values are loaded once per process, not per call
- [ ] Admin config updates clear the cache

## Work Log
- 2026-03-28: Identified during v1 deployment review
