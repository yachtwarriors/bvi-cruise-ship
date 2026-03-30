---
status: pending
priority: p1
issue_id: "003"
tags: [code-review, bug, user-accounts]
dependencies: []
---

# `email_enabled` Defaults to False With No Way to Enable

## Problem Statement
`users.email_enabled` defaults to `false`. The email rake task filters `User.email_enabled`, so no user will ever receive emails. There is no UI toggle or controller param to set `email_enabled = true`. The account page only permits `alert_start_date` and `alert_end_date`.

## Findings
- `db/schema.rb:114` — `email_enabled` defaults to `false`
- `app/models/user.rb:11` — `scope :email_enabled, -> { where(email_enabled: true) }`
- `app/controllers/accounts_controller.rb:23` — `account_params` does not permit `email_enabled`
- `app/views/accounts/show.html.erb` — no toggle for email_enabled

**Source**: kieran-rails-reviewer, security-sentinel

## Proposed Solutions

### Option 1: Auto-enable when dates are set (Simplest)
In `AccountsController#update`, set `email_enabled: true` when alert dates are saved, `false` when cleared.
- **Effort**: Small (10 min)
- **Risk**: None — implicit opt-in via date selection

### Option 2: Add checkbox to account page
Add `email_enabled` checkbox to the account form, permit it in `account_params`.
- **Effort**: Small (15 min)
- **Risk**: None — explicit opt-in

### Option 3: Default `email_enabled` to `true` in migration
Change the column default. All new registrations get emails enabled by default.
- **Effort**: Small (10 min)
- **Risk**: Low — users who sign up but don't set dates still won't get emails (the date scope filters them out)

## Acceptance Criteria
- [ ] Users with alert dates set can actually receive daily emails
- [ ] `rake email:send_daily_alerts` sends to users with active date windows

## Work Log
- 2026-03-28: Identified during v1 deployment review
