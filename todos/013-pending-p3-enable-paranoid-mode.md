---
status: pending
priority: p3
issue_id: "013"
tags: [code-review, security]
dependencies: []
---

# Enable Devise Paranoid Mode

## Problem Statement
`config.paranoid` is commented out (defaults to `false`). Password reset and login flows reveal whether an email exists in the system, enabling user enumeration.

## Findings
- `config/initializers/devise.rb:94` — `config.paranoid` commented out

**Source**: security-sentinel

## Proposed Solutions

### Option 1: Uncomment and enable
```ruby
config.paranoid = true
```
- **Effort**: Small (2 min)
- **Risk**: None

## Acceptance Criteria
- [ ] Password reset shows same message regardless of email existence

## Work Log
- 2026-03-28: Identified during v1 deployment review
