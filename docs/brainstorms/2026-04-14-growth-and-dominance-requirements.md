---
date: 2026-04-14
topic: growth-and-dominance
---

# Growth & Dominance: From 2 Pages to the Go-To BVI/USVI Cruise Tool

## Problem Frame

BVI Cruise Ship Schedule v1 is live with strong product-market fit: 30-50 daily visitors, mostly bookmarked repeat users, universally positive feedback. But the site has only 2 indexable pages targeting ~150 vol/mo in keyword volume. Meanwhile, 10,000+ monthly searches for related port and beach keywords (KD 0-3) are being answered by Reddit posts, static travel blog guides, flat calendar tools, and Facebook group threads — none of which offer crowd predictions, passenger counts, or hourly timing. The site has the data to dominate all of these SERPs but isn't on any of them.

Current Ahrefs profile (2026-04-14): DR 0.3, 2 real referring domains (traveltalkonline.com DR 34, yachtwarriors.com DR 28), 0 organic keywords ranking. Outreach campaign in progress (~200 emails sent, positive responses, link acquisition likely pending Ahrefs crawl).

## Requirements

### Port Pages (Tool Pages, Not Content)

- R1. Add `/tortola` page — live tool page showing today's ships at Road Town, total passenger count, hourly crowd forecast for The Baths / White Bay / Cane Garden Bay, port logistics info. Targets "tortola cruise port" (1,600 vol/mo, KD 0) and "tortola cruise ship schedule" (90 vol/mo) cluster.
- R2. Add `/st-thomas` page — live tool page showing today's ships at Charlotte Amalie, passenger count, hourly crowd forecast for Magens Bay / Coki Beach / National Park Beaches. Targets "st thomas cruise port" (1,700 vol/mo, KD 1) and "charlotte amalie cruise port" (400 vol/mo) cluster.
- R3. Add `/st-croix` page — live tool page showing today's ships at Frederiksted, passenger count, hourly crowd forecast for Rainbow Beach / Buck Island. Targets "st croix cruise port" (500 vol/mo, KD 0).
- R4. Each port page includes: 7-day schedule with ship names + passenger capacities, port-specific crowd forecast grid (same hourly timeline UI as existing pages), quick-reference port info (dock location, taxi availability, distance to beaches), cross-links to relevant beach pages and the main BVI/USVI schedule pages.

### Beach & Attraction Pages (Crowd Forecast Tools)

- R5. Add `/the-baths` page — live crowd forecast tool for The Baths. Shows today's crowd level, hourly intensity timeline, which ships are contributing to crowds, best time to visit today, and 7-day forecast. Targets "the baths bvi" (1,100 vol/mo, KD 3, traffic potential 3,200).
- R6. Add `/cane-garden-bay` page — same format. Targets "cane garden bay" (1,600 vol/mo, KD 3).
- R7. Add `/white-bay` page — same format. Targets "white bay jost van dyke" (100 vol/mo, KD 5).
- R8. Add `/magens-bay` page — same format for USVI. Targets "magens bay" keyword cluster.
- R9. Each beach page includes: today's crowd risk level as hero element ("LOW RISK — No cruise ships in port today" or "HIGH RISK — 3 ships, ~12,000 passengers, peak crowds 10am-2pm"), hourly timeline grid, contributing ships with passenger counts, "best time to visit" recommendation, 7-day forward forecast, cross-links to port page and schedule page.

### AI Search Optimization

- R10. Add FAQPage JSON-LD schema to all pages with 3-5 FAQs per page using real questions from Google's "People Also Ask" and Facebook group posts (e.g., "How crowded is The Baths when cruise ships are in port?", "What days do cruise ships dock in Tortola?").
- R11. Lead each page section with a direct-answer sentence containing specific data ("3 cruise ships are scheduled to visit Road Town today, carrying approximately 8,400 passengers").
- R12. Ensure `dateModified` in JSON-LD structured data reflects the last data update (scraper freshness), not build date.
- R13. Add robots.txt explicitly allowing PerplexityBot, GPTBot, and ClaudeBot (currently no robots.txt exists — codify the permissive policy).

### Shareability

- R14. Generate dynamic OG images per page per date showing the crowd forecast summary (e.g., "Tortola — Tue Apr 15: 3 Ships, 8,400 Passengers, HIGH Risk at The Baths"). When shared on Facebook/iMessage/WhatsApp, the preview card itself communicates the value.
- R15. Add a "Share This Forecast" button/link that copies a shareable URL for the current day's view (e.g., `/tortola?date=2026-04-15`). URL should resolve to that day's forecast even when shared later.

### SEO Infrastructure

- R16. Update sitemap.xml to include all new port and beach pages with daily changefreq and appropriate priorities.
- R17. Add internal cross-linking: port pages link to their beach pages, beach pages link back to port pages and schedule pages, schedule pages link to port pages. Every page should be reachable within 2 clicks.
- R18. Add breadcrumb structured data (BreadcrumbList JSON-LD) to all pages.

### Community Seeding (Non-Code)

- R19. Document a community engagement playbook: which Facebook groups, Cruise Critic threads, and TripAdvisor forums to monitor and answer questions in. Not spam — genuine answers to questions like "when are cruise ships at The Baths?" with natural links to the tool. Specific groups identified in research: BVI travel FB group (appears in Google positions 6-8), St. Thomas FB group, Cruise Critic Tortola subforum.

## Success Criteria

- 10+ indexable pages (up from 2), each targeting a distinct keyword cluster
- At least 3 pages ranking in top 10 within 90 days (KD 0-3 keywords)
- Organic traffic measurable in Ahrefs within 60 days (currently 0)
- Daily visitors from 30-50 to 150+ within 90 days
- At least one AI assistant (Perplexity or ChatGPT) cites the site when asked about BVI cruise ship crowds

## Scope Boundaries

- No new data sources or scrapers needed — all pages use existing CruiseVisit and CrowdSnapshot data
- No user-facing accounts or auth features in this effort
- No monetization features (CTAs, affiliate links) yet
- Port pages are tool pages with live data, not static editorial content or "port guides"
- No new destinations beyond current BVI + USVI coverage
- Dynamic OG images are the one new technical capability; keep implementation simple (HTML-to-image or server-rendered SVG)

## Key Decisions

- **Tool pages, not content pages:** Port and beach pages show live schedule and crowd data from the existing database. They're programmatic tool pages, not hand-written guides. This is how CruiseTimetables, MarineTraffic, and tide-forecast.com scaled — one template, many data pages.
- **Beach pages are distinct from port pages:** "The Baths BVI" and "Tortola cruise port" are different search intents. Beach pages focus on crowd forecast for that specific location. Port pages focus on the ship schedule and port logistics.
- **AI optimization is a first-class concern:** AI-referred sessions grew 527% YoY. Data-rich tool sites get 4.3x more citations. This site's unique data (crowd predictions, passenger counts) is exactly what AI assistants want to cite. Optimize for it from the start.
- **Keep existing pages intact:** The BVI homepage (/) and USVI page (/usvi) stay as-is. New pages complement them, not replace them.

## Dependencies / Assumptions

- Outreach campaign continues producing backlinks independently of this work
- Crowd calculation data (CrowdSnapshot) already exists for all locations and ports — no new modeling needed
- Dynamic OG image generation is technically feasible on Heroku (may need a simple approach like HTML-to-PNG via a service or pre-rendered images)

## Outstanding Questions

### Deferred to Planning
- [Affects R14][Technical] Best approach for dynamic OG image generation on Heroku — server-side rendering, external service, or pre-generated images?
- [Affects R1-R3][Technical] Should port pages share a controller/template with the existing pages controller, or use a new PortsController?
- [Affects R5-R8][Technical] Should beach pages use a LocationsController or be handled by a generic PagesController with slug routing?
- [Affects R10][Needs research] What are the exact "People Also Ask" questions Google shows for each target keyword? Pull during planning to populate FAQ schema.

## Next Steps

-> `/ce:plan` for structured implementation planning
