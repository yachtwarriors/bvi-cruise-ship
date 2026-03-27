# BVI Cruise Ship Schedule — Project Summary

*Last updated: 2026-03-27*

## What It Is

A standalone Rails 8 app at **bvicruiseshipschedule.com** that tracks cruise ships visiting the BVI and estimates hourly crowd risk at **The Baths** (Virgin Gorda) and **White Bay** (Jost Van Dyke). Built for yacht charter captains and guests who want to plan their day around cruise ship crowds.

**GitHub:** https://github.com/yachtwarriors/bvi-cruise-ship
**Heroku app:** cruise-ship
**Domain:** bvicruiseshipschedule.com

---

## How It Works

### Data Pipeline

1. **Daily scraper** (Heroku Scheduler) fetches cruise ship schedules from two sources:
   - **Crew Center** (crew-center.com) — near-term data (~10 days), has arrival AND departure times
   - **CruiseDig** (cruisedig.com) — extended data through 2028, paginated, often missing departure times

2. **Data storage** — each ship visit is stored as a `CruiseVisit` record with ship name, cruise line, passenger capacity, arrival/departure times, port, and source

3. **Crowd calculation** — for each date, the `CrowdCalculationService` generates hourly crowd estimates for The Baths and White Bay using a trapezoidal curve model

4. **Pre-calculated snapshots** — `CrowdSnapshot` records store the hourly intensity (green/yellow/red) so page loads are fast with no on-the-fly computation

### Crowd Model Logic

**Which ports affect which locations:**
- **The Baths:** Spanish Town ships (50% of pax), Gorda Sound ships (40% of pax), Road Town ships (20% excursion rate)
- **White Bay:** Jost Van Dyke ships only (100% of pax)

**Hourly estimate for each contributing ship:**
1. `effective_pax = passenger_capacity × 85% utilization × port contribution %`
2. Trapezoidal curve: 1-hour ramp up after arrival + transit time, flat plateau, 1-hour ramp down, clear 2 hours before departure
3. Sum all ships' contributions for each hour
4. Compare to per-location thresholds → green/yellow/red

**Key parameters (all tunable in admin):**
- Transit time: Spanish Town → Baths = 90 min, Road Town → Baths = 90 min, Gorda Sound → Baths = 120 min, JVD → White Bay = 20 min
- Capacity utilization: 85%
- Spanish Town → Baths: 50% of passengers
- Gorda Sound → Baths: 40% of passengers
- Road Town → Baths excursion: 20% of passengers
- Earliest crowd arrival: 8:30 AM (Baths), 9:00 AM (White Bay)
- Return-to-ship buffer: 2 hours before departure
- Ramp down: starts 60 min before passengers leave

**Default times when data is missing:**
- Unknown arrival (11:59 or 23:59 markers): defaults to 6:00 AM
- Missing departure: defaults to 6:00 PM

**Current thresholds:**
- The Baths: green ≤ 200, yellow ≤ 600, red > 600
- White Bay: green ≤ 100, yellow ≤ 300, red > 300

### Historical Data Preservation

- Past dates: frozen, never overwritten (for future analysis of averages)
- Future dates: refreshed on every scraper run (schedules change)
- Today and forward: recalculated after each scrape

---

## Tech Stack

- Ruby on Rails 8.0.5, Ruby 3.3.x
- PostgreSQL (Heroku Essential-0)
- Tailwind CSS v4
- Hotwire (Turbo Frames for week navigation, Stimulus for expand/collapse)
- Nokogiri + HTTParty for scraping
- Devise for admin auth
- Metamagic for SEO meta tags
- Figaro for environment variables
- Google Analytics (G-2JK6BMH8NJ)

---

## Database Models

| Model | Purpose |
|-------|---------|
| **Port** | 5 BVI ports: Road Town, Spanish Town, Jost Van Dyke, Norman Island, Gorda Sound |
| **Location** | 2 tracked attractions: The Baths, White Bay |
| **CruiseVisit** | One record per ship per day per port — raw schedule data |
| **CrowdSnapshot** | Pre-calculated hourly intensity per location per day |
| **CrowdThreshold** | Per-location green/yellow/red cutoffs (admin-editable) |
| **AppConfig** | Key-value store for tunable model parameters |
| **ScrapeLog** | Every scraper run logged with status and record count |
| **Admin** | Devise auth for admin panel |

---

## Key URLs

| URL | Purpose |
|-----|---------|
| `/` | Public landing page — hero, legend, 7-day rolling schedule |
| `/login` | Devise admin login |
| `/manage` | Admin dashboard — stats, scraper logs, recalculate button |
| `/manage/thresholds` | Edit green/yellow/red thresholds per location |
| `/manage/configs` | Edit model parameters (transit times, percentages) |
| `/sitemap.xml` | XML sitemap with daily changefreq |

---

## Heroku Setup

- **App name:** cruise-ship
- **Addons:** heroku-postgresql:essential-0
- **Scheduler task:** `rake scraper:fetch_schedules` — runs daily
- **Release command:** `rake db:migrate db:seed` (auto-runs on deploy)
- **Config vars:** SECRET_KEY_BASE, RAILS_MASTER_KEY, DATABASE_URL (auto), BUST_CACHE

---

## SEO

- **Primary keyword:** "bvi cruise ship schedule" (150/mo, difficulty 1)
- **Secondary:** "tortola cruise ship schedule" (90/mo), "tortola cruise port" (1,600/mo)
- **Meta title:** "BVI Cruise Ship Schedule — Tortola Cruise Port & Crowd Tracker"
- **Open Graph + Twitter Cards** with Baths image
- **JSON-LD:** WebApplication schema with TouristAttraction references
- **Sitemap:** daily changefreq, auto-updated lastmod from last scrape
- **robots.txt:** points to sitemap

---

## Data Sources

### Crew Center (crew-center.com) — Primary
- Server-rendered HTML tables, Nokogiri parsing
- 5 port pages (Road Town, Spanish Town, JVD, Norman Island, Gorda Sound)
- Has arrival AND departure times
- European decimal passenger counts (2.198 = 2,198)
- Limited window (~10-15 days for Road Town)

### CruiseDig (cruisedig.com) — Extended Range
- Same team as Crew Center, paginated lists
- Goes through March 2028
- Often missing departure times (defaults to 6pm)
- 11:59 and 23:59 are "time unknown" markers (default to 6am arrival)

### Ship Capacity Reference
- `db/seeds/ship_capacities.yml` — 170+ ships mapped to max passenger capacity
- Used as fallback when scraper doesn't provide capacity
- Ships flagged as `capacity_estimated: true` when using lookup

---

## Scraper Edge Cases Handled

- **European decimal notation:** `2.198` → 2,198 passengers
- **23:59 arrival/departure:** treated as "time unknown," defaults applied
- **11:59 arrival:** same treatment (CruiseDig uses this as placeholder)
- **Missing departure time:** defaults to 6:00 PM
- **Missing arrival time:** defaults to 6:00 AM
- **Missing passenger capacity:** lookup from ship reference table, flagged as estimated
- **Crew Center preferred over CruiseDig** when both have data for the same visit

---

## Admin Credentials (dev/production)

- **Email:** matt@yachtwarriors.com
- **Password:** password (change in production!)

---

## What's Next

- **Tune thresholds** — watch real data over a month, adjust green/yellow/red cutoffs
- **Tune model parameters** — excursion percentages and transit times based on observation
- **More content pages** for SEO (blog posts about avoiding cruise crowds, best times to visit, etc.)
- **Historical analytics** — past data is preserved for calculating averages, above/below average indicators
- **PortCall integration** — the BVI PortCall system (bvi.portcall.com) has the most accurate real-time data with exact anchorage locations (Spanish Town North/South, JVD-White Bay vs JVD-Great Harbor, Gorda Sound 1/2). Could be a future data source upgrade.
