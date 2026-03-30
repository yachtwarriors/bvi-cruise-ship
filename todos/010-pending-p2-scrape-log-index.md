---
status: pending
priority: p2
issue_id: "010"
tags: [code-review, performance, database]
dependencies: []
---

# Missing Index on scrape_logs Table

## Problem Statement
`scrape_logs` has no index on `source`, `status`, or `scraped_at`. `ScraperMonitorService.check_data_freshness` queries `WHERE status = 'success' AND source = ?` with `ORDER BY scraped_at DESC`. Will degrade over months of accumulated logs.

## Findings
- `db/schema.rb:96-104` — no indexes on scrape_logs
- `app/models/scrape_log.rb` — `recent` scope orders by `scraped_at DESC`

**Source**: kieran-rails-reviewer, architecture-strategist

## Proposed Solutions

### Option 1: Add composite index (Recommended)
```ruby
add_index :scrape_logs, [:source, :status, :scraped_at]
```
- **Effort**: Small (10 min)
- **Risk**: None

## Acceptance Criteria
- [ ] Composite index exists on scrape_logs

## Work Log
- 2026-03-28: Identified during v1 deployment review
