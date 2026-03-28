---
date: 2026-03-28
topic: v2-ops-features-monetization
---

# V2: Ops, User Accounts & Notifications, Monetization

## Problem Frame
V1 is live and getting positive feedback (~20 users). Three gaps need addressing:
1. **Ops** — scraper monitoring isn't wired up (Slack webhook empty, scheduler may not be configured), so failures go unnoticed
2. **Retention** — users visit once to check crowds, no reason to return. Charter guests need daily alerts for their trip dates (typically 1 week to 1 month)
3. **Monetization** — free tool with no revenue path. Audience overlaps heavily with Yacht Warriors and CharterProtect customers

## Stream 1: Ops & Monitoring

### Requirements
- R1. Slack webhook configured on Heroku for scraper alerts (errors, warnings, stale data)
- R2. Heroku Scheduler verified running `rake scraper:fetch_schedules` (twice daily)
- R3. Rake task wrapped with error handling so unrescued exceptions trigger Slack alerts
- R4. Per-source freshness tracking (alert if Crew Center OR CruiseDig individually stale >48hrs)

### Success Criteria
- Scraper failure produces a Slack alert within minutes
- Matt knows if data stops flowing without having to check manually

## Stream 2: User Accounts & Daily Email Alerts

### Requirements
- R5. User sign-up/login via Devise (email + password). Simple registration — no invite-only, no social auth
- R6. Standard Devise flows: sign up, log in, log out, forgot password, change password
- R7. Users set "alert dates" — a date range (start/end) for when they want daily emails
- R8. Daily morning email (via Postmark) sent to users whose alert window includes today. Shows: ships in port, passenger count, crowd risk summary for The Baths / White Bay / Cane Garden Bay, best time to visit each location
- R9. Users can update or remove their date range at any time from their account
- R10. Start with daily email to Matt only (hardcoded or feature flag) before opening to all users

### Success Criteria
- User can sign up, set "Mar 30 – Apr 5" as their alert window, and receive a daily email each morning during that window
- Email is useful standalone — user doesn't need to visit the site to get the key info
- Postmark delivery confirmed working

### Key Decisions
- **Devise for users (separate from Admin model):** Admin already uses Devise. Users get their own Devise model (User) with separate registration
- **Postmark for transactional email:** Same gem/setup as Yacht Warriors (postmark-rails)
- **Date range, not individual dates:** Users pick a start and end date. Simpler UX than selecting individual days
- **No email frequency options:** Daily only. Keep it simple
- **Morning send time:** ~6:30 AM AST (before users head out for the day)

## Stream 3: Monetization Foundation

### Requirements
- R11. Contextual Yacht Warriors CTA on high-crowd days — "Avoid the crowds? Book a private yacht charter" with link to yachtwarriors.com
- R12. CharterProtect affiliate link in footer or email — "Protect your charter booking"
- R13. Cross-sell placement in daily email (YW + CharterProtect)

### Success Criteria
- YW CTA appears naturally on red/yellow crowd days without feeling spammy
- Email includes YW and CharterProtect mentions that feel helpful, not salesy
- Click tracking confirms users are clicking through

## Scope Boundaries
- No social auth (Google, Facebook) — email/password only
- No push notifications or SMS — email only for now
- No premium/paid tier — everything stays free
- No display ads
- No location-specific pages yet (future SEO work)
- No weekly digest — daily email only during user's active window
- No user-submitted crowd reports (future UGC)

## Dependencies / Assumptions
- Heroku Scheduler already provisioned (user confirmed)
- Postmark account exists (used for Yacht Warriors — may need separate server/API key for this app)
- Slack workspace exists with a channel for alerts

## Next Steps
Three parallel implementation plans: ops, user accounts + email, monetization CTAs
