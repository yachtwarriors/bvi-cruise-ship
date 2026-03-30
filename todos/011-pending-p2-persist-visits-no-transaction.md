---
status: pending
priority: p2
issue_id: "011"
tags: [code-review, architecture, data-integrity]
dependencies: []
---

# persist_visits Has No Transaction Wrapper

## Problem Statement
`ScraperOrchestratorService#persist_visits` saves each visit individually without a transaction. If the process fails mid-batch, you get partially-persisted scrape data with no rollback — a mix of stale and fresh records for the same date.

## Findings
- `app/services/scraper_orchestrator_service.rb:46-77` — each `visit.save!` is an independent commit

**Source**: architecture-strategist

## Proposed Solutions

### Option 1: Wrap in ActiveRecord::Base.transaction
```ruby
def persist_visits(visits)
  count = 0
  ActiveRecord::Base.transaction do
    visits.each do |attrs|
      # ... existing logic ...
    end
  end
  count
end
```
- **Effort**: Small (5 min)
- **Risk**: None

## Acceptance Criteria
- [ ] persist_visits is atomic — all or nothing per scrape source

## Work Log
- 2026-03-28: Identified during v1 deployment review
