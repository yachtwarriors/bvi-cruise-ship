---
status: pending
priority: p2
issue_id: "009"
tags: [code-review, security]
dependencies: []
---

# Content Security Policy Not Enabled

## Problem Statement
The CSP initializer is entirely commented out. No `Content-Security-Policy` header is sent. If any XSS vector were introduced, the browser has no second line of defense.

## Findings
- `config/initializers/content_security_policy.rb` — all commented out
- Google Analytics inline script would need nonce or `unsafe-inline` allowance

**Source**: security-sentinel

## Proposed Solutions

### Option 1: Enable CSP in report-only mode first, then enforce
Start with `config.content_security_policy_report_only = true` to catch violations without breaking anything.
- **Effort**: Medium (30 min)
- **Risk**: Low — report-only mode won't break anything

## Acceptance Criteria
- [ ] CSP header is present in production responses
- [ ] Google Analytics and Tailwind CSS still work

## Work Log
- 2026-03-28: Identified during v1 deployment review
