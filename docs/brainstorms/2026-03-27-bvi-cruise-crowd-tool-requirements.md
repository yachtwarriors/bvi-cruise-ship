---
date: 2026-03-27
topic: bvi-cruise-crowd-tool
---

# BVI Cruise Ship Crowd Tool

## Problem Frame

Charter captains and guests in the BVI want to visit popular spots like The Baths and White Bay without fighting cruise ship crowds. The only way to check today is to dig through the official BVI cruise schedule (buried on government sites) or third-party schedule listings — none of which tell you *when during the day* crowds will peak, how many total passengers are in port, or how multiple overlapping ships compound the problem. There is no tool anywhere that turns raw schedule data into actionable crowd timing advice.

## Requirements

- R1. **Daily cruise ship data:** For each day, show which cruise ships are in BVI — ship name, cruise line, passenger capacity, arrival time, departure time, and which port they're at (Road Town, Spanish Town/Virgin Gorda, Jost Van Dyke, Norman Island).
- R2. **Hourly crowd intensity for The Baths:** Using ship arrival/departure times at Spanish Town/Virgin Gorda + passenger counts + estimated transit time to The Baths, generate an hour-by-hour crowd intensity view. Account for overlapping ships compounding the crowd.
- R3. **Hourly crowd intensity for White Bay:** Same as R2 but for ships anchored at Jost Van Dyke, with crowd estimates at White Bay beach bars.
- R4. **This Week default view:** Landing page shows today + the rest of the current week. Optimized for mobile (charter guests on phones). Each day shows ships in port and the hourly crowd breakdown for The Baths and White Bay.
- R5. **Browse future dates:** Users can look ahead to see upcoming weeks/months for trip planning purposes.
- R6. **Automated data ingestion:** Daily scrape of Crew Center (primary source) via Heroku Scheduler. No manual data entry.
- R7. **Scraper health monitoring:** Alert (via logs, email, or Slack) if the scraper fails, returns no data, or returns data that looks structurally different from expected. The system should know when it's not getting reliable updates.
- R8. **Configurable thresholds:** Green/yellow/red crowd levels are admin-configurable, not hardcoded. Thresholds will be tuned after observing real data over ~1 month.
- R9. **Standalone site:** Own domain (TBD), own Rails app. Small YW attribution link (similar to bathsflagstatus.com style).

## Success Criteria

- A charter guest can pull up the site on their phone and within seconds understand whether today is a good day to visit The Baths or White Bay, and what time window is best.
- Data stays current without any manual intervention from Matt.
- Matt knows promptly if the scraper breaks.

## Scope Boundaries

- **No user accounts or login** (public tool, no auth needed for visitors)
- **No commercial monetization** — this is a fun/utility project
- **No real-time AIS ship tracking** — we use published schedules, not live position data
- **Admin for threshold tuning only** — Devise admin behind /login, minimal UI, just to adjust crowd thresholds
- **Two locations only:** The Baths and White Bay. Not a general-purpose BVI crowd tool
- **No Norman Island / Caves rating** — too low volume to matter

## Key Decisions

- **Scrape, don't API:** No free cruise schedule APIs exist. Crew Center is the primary scrape target — server-rendered HTML tables, all needed data fields, covers 4 BVI ports.
- **Hourly crowd model over daily rating:** A single green/yellow/red per day isn't useful enough. The real value is showing *when* during the day it'll be crowded so captains can time their visit.
- **Crowd model inputs:** Passenger capacity × arrival/departure times × port location × estimated transit time to attraction. Multiple ships compound (additive passenger counts during overlap windows).
- **Heroku Scheduler for scraping:** Daily job, same pattern as Housekeeper. Monitoring built in from day one.

## Dependencies / Assumptions

- Crew Center continues to serve schedule data in scrapeable HTML tables. If they change structure, scraper needs updating (R7 monitoring will catch this).
- Estimated transit times from port to attraction (e.g., Spanish Town dock → The Baths ≈ 90 min for cruise guests via ferry + taxi/shuttle) are based on Matt's local knowledge. These are configurable assumptions, not hard science.
- Cruise ship passenger capacity numbers from Crew Center are maximum capacity, not actual passenger counts. Real crowds will be some percentage of max — another tunable parameter.

## Outstanding Questions

### Resolve Before Planning
*None — all product decisions resolved.*

### Deferred to Planning
- [Affects R2, R3][Needs research] What are reasonable transit time estimates from each port to The Baths and White Bay? (e.g., Spanish Town ferry dock → Baths = ~90 min for cruise excursion groups)
- [Affects R2, R3][Technical] What crowd curve shape should we model? Linear ramp-up from arrival, bell curve peaking mid-visit, or flat plateau? Probably start simple (linear ramp up, flat during stay, drop off after departure).
- [Affects R6][Technical] Exact Crew Center URL structure and HTML parsing strategy for all 4 BVI ports.
- [Affects R7][Technical] Monitoring channel — Slack (like Housekeeper), email, or just Rails logs + error tracking?
- [Affects R8][Technical] Admin UI for threshold config — ActiveAdmin, or a simple custom page behind Devise?
- [Affects R5][Technical] How far ahead does Crew Center publish schedule data? This determines how far in advance users can browse.

## Next Steps

→ `/ce:plan` for structured implementation planning
