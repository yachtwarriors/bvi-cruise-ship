# Ops & Monitoring Plan

**Date:** 2026-03-28
**Scope:** 3 code changes + manual Heroku/Slack config

## Current State
Monitoring code is 80% built. ScraperMonitorService sends Slack alerts via `AppConfig.get("slack_webhook_url")` — but the webhook URL is empty. Per-source error handling exists in the orchestrator, but freshness checks are global (not per-source) and the rake task has no top-level error handling.

## Step 1: Slack Webhook (R1) — Manual Config

1. Create Slack Incoming Webhook for target channel (e.g., `#cruise-ship-alerts`)
2. Set in production: `heroku run rails console -a cruise-ship` → `AppConfig.set("slack_webhook_url", "https://hooks.slack.com/services/XXX", description: "Slack webhook for scraper alerts")`
3. Test: `heroku run rails runner "ScraperMonitorService.send_alert('Test alert')" -a cruise-ship`

## Step 2: Heroku Scheduler Verification (R2) — Manual Config

1. `heroku addons -a cruise-ship` — confirm Scheduler addon exists
2. `heroku addons:open scheduler -a cruise-ship` — verify two daily jobs exist for `rake scraper:fetch_schedules`
3. If not: create two daily jobs at ~06:00 UTC and ~18:00 UTC

## Step 3: Rake Task Error Handling (R3)

**File: `lib/tasks/scraper.rake`**

Wrap the task body with begin/rescue. If something outside the per-source blocks blows up (e.g., `recalculate_crowds`, DB connection error), alert Slack and re-raise.

```ruby
namespace :scraper do
  desc "Fetch cruise ship schedules and recalculate crowd intensities"
  task fetch_schedules: :environment do
    puts "[#{Time.current}] Starting cruise ship schedule scrape..."
    ScraperOrchestratorService.run
    puts "[#{Time.current}] Scrape complete."
  rescue => e
    ScraperMonitorService.send_alert(
      "🚨 Fatal scraper error: #{e.class}: #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}"
    )
    raise
  end
end
```

## Step 4: Per-Source Freshness Tracking (R4)

**File: `app/models/scrape_log.rb`** — Add scope:
```ruby
def self.last_successful_for(source)
  where(status: "success", source: source).recent.first
end
```

**File: `app/services/scraper_monitor_service.rb`** — Replace `check_data_freshness`:
```ruby
def self.check_data_freshness
  %w[crew_center cruisedig].each do |source|
    last_success = ScrapeLog.last_successful_for(source)
    if last_success.nil?
      send_alert("⚠️ No successful scrape ever recorded for #{source}")
      next
    end
    hours_since = ((Time.current - last_success.scraped_at) / 1.hour).round
    if hours_since > 48
      send_alert("⚠️ Stale data [#{source}]: Last successful scrape was #{hours_since} hours ago")
    end
  end
end
```

## File Change Summary

| File | Change |
|------|--------|
| `lib/tasks/scraper.rake` | Add begin/rescue wrapper (~5 lines) |
| `app/models/scrape_log.rb` | Add `last_successful_for` scope (~3 lines) |
| `app/services/scraper_monitor_service.rb` | Rewrite `check_data_freshness` per-source (~12 lines) |

## Testing
1. Run `rake scraper:fetch_schedules` locally with webhook URL set — confirm Slack message
2. Break a scraper URL to trigger per-source error — confirm Slack alert
3. Set stale `scraped_at` on one source's ScrapeLog — confirm only that source triggers freshness alert
4. Raise exception before `ScraperOrchestratorService.run` — confirm fatal alert fires
