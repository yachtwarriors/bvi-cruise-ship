---
status: pending
priority: p1
issue_id: "001"
tags: [code-review, rails, bug]
dependencies: []
---

# Broken `admin_*_path` Route Helpers in Manage Controllers

## Problem Statement
All three Manage controllers reference `admin_*_path` route helpers that don't exist. The namespace is `manage`, not `admin`. Any successful update/recalculate action in the admin panel will crash with `NoMethodError`.

## Findings
- `manage/configs_controller.rb:10` — `admin_configs_path` should be `manage_configs_path`
- `manage/thresholds_controller.rb:10` — `admin_thresholds_path` should be `manage_thresholds_path`
- `manage/dashboard_controller.rb:14` — `admin_root_path` should be `manage_root_path`

**Source**: kieran-rails-reviewer, code-simplicity-reviewer

## Proposed Solutions

### Option 1: Fix route helper names (Recommended)
Replace all three references with the correct `manage_*_path` helpers.
- **Pros**: Simple, correct
- **Cons**: None
- **Effort**: Small (5 min)
- **Risk**: None

## Acceptance Criteria
- [ ] `manage/configs_controller.rb` redirects to `manage_configs_path`
- [ ] `manage/thresholds_controller.rb` redirects to `manage_thresholds_path`
- [ ] `manage/dashboard_controller.rb` redirects to `manage_root_path`
- [ ] Updating a config, threshold, and triggering recalculate all work without error

## Work Log
- 2026-03-28: Identified during v1 deployment review
