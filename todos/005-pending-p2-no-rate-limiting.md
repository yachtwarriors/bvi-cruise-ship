---
status: pending
priority: p2
issue_id: "005"
tags: [code-review, security]
dependencies: []
---

# No Rate Limiting (rack-attack)

## Problem Statement
No rate limiting on login, registration, or password reset endpoints. An attacker could brute-force admin login, mass-register accounts, or trigger bulk password reset emails.

## Findings
- No `rack-attack` gem in Gemfile
- Admin login at `/login` has no lockout (`:lockable` not enabled)
- User registration at `/users/signup` is open with no throttle
- Password reset at `/users/password/new` has no throttle

**Source**: security-sentinel

## Proposed Solutions

### Option 1: Add rack-attack with basic throttles (Recommended)
Add `rack-attack` gem, configure throttles for login (5/min/IP), registration (3/hr/IP), password reset (3/hr/email).
- **Effort**: Medium (1 hour)
- **Risk**: Low

### Option 2: Add Devise :lockable to Admin model (Quick win)
Enable `:lockable` on Admin with `failed_attempts` column. Locks account after 5 failed attempts.
- **Effort**: Small (30 min)
- **Risk**: Low

## Acceptance Criteria
- [ ] Repeated failed logins are throttled or locked
- [ ] Mass registration attempts are blocked

## Work Log
- 2026-03-28: Identified during v1 deployment review
