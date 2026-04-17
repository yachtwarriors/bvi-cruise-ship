---
title: "feat: Add Port Pages, Beach Pages, and SEO Infrastructure for Traffic Growth"
type: feat
status: active
date: 2026-04-14
origin: docs/brainstorms/2026-04-14-growth-and-dominance-requirements.md
---

# Add Port Pages, Beach Pages, and SEO Infrastructure

## Overview

Expand bvicruiseshipschedule.com from 2 indexable pages targeting ~150 vol/mo to 14+ pages targeting ~10,000+ vol/mo. Add port-specific pages (`/tortola`, `/virgin-gorda`, `/st-thomas`, `/st-croix`) and beach/attraction pages (`/the-baths`, `/cane-garden-bay`, `/white-bay`, `/magens-bay`, `/coki-beach`, `/national-park-beaches`, `/rainbow-beach`, `/buck-island`) — all as live tool pages powered by existing CruiseVisit and CrowdSnapshot data. Add AI search optimization (FAQPage schema, robots.txt), SEO infrastructure (sitemap, breadcrumbs, canonical URLs, cross-linking), and shareable forecast URLs.

## Problem Statement / Motivation

The site has strong product-market fit (30-50 daily visitors, all bookmarks/word-of-mouth) but 0 organic keywords ranking in Ahrefs. The SERP landscape is wide open: "tortola cruise port" (1,600 vol/mo, KD 0) has a DR 6 blog with 0 backlinks at #3. "St thomas cruise port" (1,700 vol/mo, KD 1) is dominated by generic sites. Facebook group posts rank #6-8 for almost every relevant keyword — people asking the exact questions this tool answers. No competitor offers crowd predictions, passenger counts, or hourly timing. (see origin: `docs/brainstorms/2026-04-14-growth-and-dominance-requirements.md`)

### GSC Validation (2026-04-15, last 3 months)

Google Search Console confirms organic demand. 53 clicks, 641 impressions across 22 unique queries. Key findings:

**High-value queries already showing impressions:**
| Query | Impressions | Clicks | Avg Position |
|-------|------------|--------|-------------|
| bvi cruise ship schedule | 25 | 6 | 11.3 |
| tortola cruise ship schedule | 10 | 0 | 12.2 |
| road town cruise ship schedule | 5 | 0 | 9.0 |
| bvi cruise ship schedule 2026 | 4 | 0 | 7.8 |
| tortola cruise schedule | 4 | 0 | 7.8 |
| cruise ships in tortola today | 4 | 0 | 8.3 |
| tortola port schedule | 4 | 0 | 8.3 |
| bvi port authority cruise ship schedule | 4 | 0 | 9.5 |
| tortola cruise port schedule | 3 | 0 | 10.0 |
| virgin gorda cruise ship schedule | 2 | 0 | 17.5 |
| best time to visit the baths | 1 | 0 | **1.0** |
| cruise ships in tortola tomorrow | 1 | 0 | 4.0 |
| cruise ship schedule st croix | 1 | 0 | 46.0 |
| cruise ship schedule st thomas usvi | 1 | 0 | 75.0 |
| port of st thomas cruise ship schedule | 1 | 0 | 85.0 |

**Implications for this plan:**
- Tortola queries dominate (7 of 22) — `/tortola` page is the highest-priority port page
- "best time to visit the baths" already ranking **position 1** — `/the-baths` page will capture this with a dedicated crowd forecast
- "virgin gorda cruise ship schedule" (pos 17.5) — added `/virgin-gorda` port page to capture this (Spanish Town + Gorda Sound ports exist in DB)
- "cruise ships in tortola today/tomorrow" — temporal intent validates live tool approach over static content
- St Thomas (pos 75) and St Croix (pos 46) are barely visible — dedicated pages should push these into top 10
- **60+ indexed `?start_date=` URL variants** in GSC Pages data — canonical URLs (Phase 4) are urgent to consolidate crawl budget
- FAQ schema (Phase 5) should use exact GSC query language, not invented questions

## Key Decisions (from origin)

- **Tool pages, not content pages** — programmatic pages showing live data, not hand-written port guides
- **All 8 beach pages, not just 4** — same template, near-zero incremental cost, avoids broken links from port pages
- **AI optimization is first-class** — FAQPage schema, direct-answer formatting, bot-friendly robots.txt
- **No new scrapers or data sources** — everything uses existing CruiseVisit + CrowdSnapshot data
- **No monetization in this effort** — pure traffic growth
- **Dynamic OG images deferred** — use existing static beach photos for now; dynamic per-day images are a follow-up

## Proposed Solution

### Architecture

**Port pages:** New `PortsController` with a `show` action. Loads a single port by slug, its locations, visits, and snapshots. Same query pattern as `UsviController`. Route: `get "/:slug" => "ports#show"` with constraint limiting to known port slugs.

**Beach pages:** New `LocationsController` with a `show` action. Loads a single location by slug, finds contributing ports, loads relevant visits and snapshots. Route: `get "/:slug" => "locations#show"` with constraint limiting to known location slugs.

**Routing strategy:** Use explicit named routes rather than a catch-all `/:slug` to avoid conflicts and keep routes debuggable:

```ruby
# Port pages
get "/tortola" => "ports#show", slug: "road-town", as: :tortola
get "/virgin-gorda" => "ports#show", slug: "spanish-town", as: :virgin_gorda
get "/st-thomas" => "ports#show", slug: "charlotte-amalie", as: :st_thomas
get "/st-croix" => "ports#show", slug: "frederiksted", as: :st_croix

# Beach/attraction pages
get "/the-baths" => "locations#show", slug: "the-baths", as: :the_baths
get "/cane-garden-bay" => "locations#show", slug: "cane-garden-bay", as: :cane_garden_bay
get "/white-bay" => "locations#show", slug: "white-bay", as: :white_bay
get "/magens-bay" => "locations#show", slug: "magens-bay", as: :magens_bay
get "/coki-beach" => "locations#show", slug: "coki-beach", as: :coki_beach
get "/national-park-beaches" => "locations#show", slug: "national-park-beaches", as: :national_park_beaches
get "/rainbow-beach" => "locations#show", slug: "rainbow-beach", as: :rainbow_beach
get "/buck-island" => "locations#show", slug: "buck-island", as: :buck_island
```

Place these BEFORE the `namespace :manage` block but AFTER root and `/usvi` routes. Devise routes come first, then root, then /usvi, then port pages, then beach pages, then manage namespace.

**Shared partials:** Extract duplicated UI from `home.html.erb` and `usvi/show.html.erb` into `app/views/shared/` partials. These are reused by all new pages.

### Data Flow

No new models or migrations. All pages query existing tables:

```
Port (by slug) -> CruiseVisit (in date range) -> CrowdSnapshot (by location, in date range)
Location (by slug) -> Location.port -> CruiseVisit -> CrowdSnapshot
```

The `contributing_port?` helper needs expansion to cover all 8 locations (currently only handles The Baths and White Bay).

### Content Differentiation (No Duplicate Content)

- **`/` (BVI homepage):** Multi-port BVI overview showing ALL BVI ports and ALL BVI locations. Weekly schedule view. Targets "bvi cruise ship schedule."
- **`/tortola`:** Single-port view for Road Town only. Shows Road Town ships + crowd forecasts for beaches reachable from Road Town (The Baths via excursion, Cane Garden Bay via taxi, White Bay via water taxi). Includes 3-5 bullets of port logistics (dock location, taxi stand, walking distance). Targets "tortola cruise ship schedule" (GSC: 10 imp, pos 12.2).
- **`/virgin-gorda`:** Combined view for Spanish Town + Gorda Sound ports. Shows ships at both ports + crowd forecast for The Baths (primary attraction). Targets "virgin gorda cruise ship schedule" (GSC: 2 imp, pos 17.5).
- **`/the-baths`:** Single-location crowd forecast focused entirely on The Baths. Hero element is today's crowd risk. Shows contributing ships from ALL ports (Spanish Town direct, Road Town excursion, Gorda Sound). "Best time to visit" recommendation. Targets "best time to visit the baths" (GSC: pos **1.0**) and "the baths bvi."
- **Canonical URLs:** Each page is self-canonical. `?start_date=` variants use `rel=canonical` pointing to the undated version. No cross-canonicalization between pages.

---

## Implementation Phases

### Phase 1: Extract Shared Partials

**Goal:** DRY up the existing views before adding new pages. This is the prerequisite for everything else.

#### Tasks

- [ ] **`app/views/shared/_timeline_legend.html.erb`** — Extract the "How to Read the Hourly Timeline" box (lines 52-72 of `home.html.erb`). No parameters needed.
- [ ] **`app/views/shared/_week_navigation.html.erb`** — Extract prev/next arrows + date picker (lines 91-120 of `home.html.erb`). Parameters: `path_helper` (the route helper for building links), `start_date`, `prev_week_start`, `next_week_start`, `today`.
- [ ] **`app/views/shared/_location_card.html.erb`** — Extract the location risk section (lines 174-212 of `home.html.erb`): icon, name, risk badge, hourly timeline grid. Parameters: `location`, `snapshots` (array for one date+location), `peak` intensity.
- [ ] **`app/views/shared/_day_card.html.erb`** — Extract the full day card (lines 128-217): day header, ship info, location cards. Parameters: `date`, `visits`, `locations`, `snapshots`, `today`.
- [ ] **Refactor `home.html.erb`** to use the new partials. Verify visually identical output.
- [ ] **Refactor `usvi/show.html.erb`** to use the new partials. Verify visually identical output.
- [ ] **Expand `contributing_port?` helper** (`app/helpers/pages_helper.rb:75-84`) to cover all 8 locations:
  - Cane Garden Bay: Road Town ships
  - Magens Bay: Charlotte Amalie ships
  - Coki Beach: Charlotte Amalie ships
  - National Park Beaches: Charlotte Amalie ships
  - Rainbow Beach: Frederiksted ships
  - Buck Island: Frederiksted ships

#### Acceptance Criteria
- [ ] Both existing pages render identically before and after refactor (visual test in browser)
- [ ] All partials accept explicit locals (no instance variables)
- [ ] `contributing_port?` returns correct port associations for all 8 locations

---

### Phase 2: Port Pages

**Goal:** Add `/tortola`, `/st-thomas`, `/st-croix` as live tool pages.

#### Tasks

- [ ] **Create `app/controllers/ports_controller.rb`**
  - `show` action following the UsviController pattern
  - Look up port by slug from route params (`params[:slug]`)
  - Load locations for that port with `.includes(:crowd_threshold)`
  - For `/tortola` (Road Town): also show locations reachable via excursion — The Baths (Road Town excursion), White Bay (water taxi), Cane Garden Bay (taxi). Use a port-to-locations mapping, not `port.locations` alone since some locations span multiple contributing ports.
  - For `/virgin-gorda` (Spanish Town + Gorda Sound): show The Baths (primary draw). Two ports feed into one page — aggregate visits from both Spanish Town and Gorda Sound.
  - For `/st-thomas` (Charlotte Amalie): show Magens Bay, Coki Beach, National Park Beaches
  - For `/st-croix` (Frederiksted): show Rainbow Beach, Buck Island
  - Same 7-day date window logic as existing controllers
  - Set page-specific meta data (title, description, keywords, OG tags)

- [ ] **Create `app/views/ports/show.html.erb`**
  - Hero section with port-specific background image and title (e.g., "Tortola Cruise Port — Road Town Schedule & Crowd Tracker")
  - Port logistics section: 3-5 static bullet points per port (dock name, taxi availability, distance to beaches). Hardcoded in view, kept minimal per origin scope boundary.
  - Reuse `_timeline_legend`, `_week_navigation`, `_day_card` partials
  - Cross-link banner to related beach pages
  - Cross-link to main BVI or USVI schedule page
  - "How does this work?" section (port-specific version)
  - Yacht Warriors footer attribution

- [ ] **Add routes** in `config/routes.rb` as specified in Architecture section above

- [ ] **Meta tags per port page:**
  - `/tortola`: title "Tortola Cruise Ship Schedule — Road Town Port Crowd Tracker", targeting "tortola cruise ship schedule" (10 imp, pos 12.2 in GSC), "tortola cruise port" (1,600 vol/mo)
  - `/virgin-gorda`: title "Virgin Gorda Cruise Ship Schedule — Spanish Town Port & The Baths Crowd Tracker", targeting "virgin gorda cruise ship schedule" (2 imp, pos 17.5 in GSC)
  - `/st-thomas`: title "St. Thomas Cruise Ship Schedule — Charlotte Amalie Port Crowd Tracker", targeting "cruise ship schedule st thomas usvi" (GSC pos 75), "st thomas cruise port" (1,700 vol/mo)
  - `/st-croix`: title "St. Croix Cruise Ship Schedule — Frederiksted Port Crowd Tracker", targeting "cruise ship schedule st croix" (GSC pos 46), "st croix cruise port" (500 vol/mo)

- [ ] **Port-to-locations mapping** — Create a hash or method in the controller (or model concern) that maps each port slug to its relevant locations. This is NOT `port.locations` because some locations are reachable from ports they don't belong to (e.g., The Baths is reachable from Road Town via ferry excursion but `belongs_to` Spanish Town port).

  Mapping:
  ```
  road-town -> The Baths, White Bay, Cane Garden Bay
  spanish-town + gorda-sound (Virgin Gorda) -> The Baths
  charlotte-amalie -> Magens Bay, Coki Beach, National Park Beaches
  frederiksted -> Rainbow Beach, Buck Island
  ```

#### Acceptance Criteria
- [ ] `/tortola` shows Road Town ships with crowd forecasts for The Baths, White Bay, Cane Garden Bay
- [ ] `/virgin-gorda` shows Spanish Town + Gorda Sound ships with crowd forecast for The Baths
- [ ] `/st-thomas` shows Charlotte Amalie ships with crowd forecasts for Magens Bay, Coki Beach, National Park Beaches
- [ ] `/st-croix` shows Frederiksted ships with crowd forecasts for Rainbow Beach, Buck Island
- [ ] Week navigation works (prev/next/date picker)
- [ ] Empty state works (day with no ships shows "No planned visits")
- [ ] Pages render correctly on mobile
- [ ] Meta tags and OG tags are correct per page (check with browser dev tools)

---

### Phase 3: Beach / Attraction Pages

**Goal:** Add all 8 beach pages as crowd forecast tools.

#### Tasks

- [ ] **Create `app/controllers/locations_controller.rb`**
  - `show` action
  - Look up location by slug from route params
  - Find contributing ports using the same mapping from Phase 2 (inverse direction: location -> which ports send crowds here)
  - Load visits from contributing ports for the date range
  - Load snapshots for this single location for the date range
  - Compute "best time to visit today": scan today's hourly snapshots (7-17), find the first window of 2+ consecutive green hours. If none, find yellow windows. If all red, recommend "early morning (before 10am) or late afternoon (after 3pm)."

- [ ] **Create `app/views/locations/show.html.erb`**
  - **Hero element** — Today's crowd risk as the dominant visual:
    - Green: "Low Risk — No significant cruise ship crowds expected today"
    - Yellow: "Moderate Risk — Some cruise ship visitors expected. Best time: [X-Y]"
    - Red: "High Risk — [N] ships in port today carrying [X] passengers. Best time: [X-Y]"
    - No ships: "No cruise ships scheduled today at [location]"
  - **Today's hourly timeline** using `_location_card` partial (larger/prominent)
  - **Contributing ships** — List of ships contributing to this location's crowds today, with names and passenger counts. Use expanded `contributing_port?` logic.
  - **7-day forward forecast** — Mini version: one row per day showing date, ship count, passenger total, peak intensity badge. Reuse data from the 7-day window query. Distinguish "no data" from "no ships" — if no CruiseVisit records exist for a date but it's within scraper range, show "No ships scheduled." If beyond scraper range, show "Schedule not yet available."
  - **Cross-links** — Link to parent port page, main schedule page, and other beaches in the same territory
  - **Location-specific "About" section** — 2-3 sentences about the location (static, hardcoded). Keep minimal per origin scope boundary.
  - Beach-specific background image in hero (use existing images: `the-baths-3.jpg`, `white-bay-bvi-3.jpg`, `magens-bay.jpg`, `north-sound-4.jpg`; source or generate images for others)

- [ ] **Add routes** in `config/routes.rb` as specified in Architecture section

- [ ] **Meta tags per beach page** — Each gets unique title, description, and keywords targeting location-specific searches. Examples:
  - `/the-baths`: "The Baths BVI Crowd Forecast — Best Time to Visit Today"
  - `/cane-garden-bay`: "Cane Garden Bay Crowd Forecast — Cruise Ship Crowd Tracker"
  - `/magens-bay`: "Magens Bay Crowd Forecast — St. Thomas Cruise Ship Crowds"

#### Acceptance Criteria
- [ ] All 8 beach pages render with correct crowd data for their location
- [ ] Hero shows today's crowd risk with appropriate color and message
- [ ] "Best time to visit" recommendation displays for today
- [ ] Contributing ships listed with names and passenger counts
- [ ] 7-day forward forecast shows correct data
- [ ] Empty states handled: no ships, no data beyond scraper range
- [ ] Cross-links to port page and schedule page work
- [ ] Mobile responsive

---

### Phase 4: SEO Infrastructure

**Goal:** Sitemap, canonical URLs, breadcrumbs, cross-linking, robots.txt.

#### Tasks

- [ ] **Update `SitemapController`** (`app/controllers/sitemap_controller.rb`) — Add all 12 new pages to `@urls` array:
  - 4 port pages (priority 0.8)
  - 8 beach pages (priority 0.7)
  - All with `changefreq: "daily"` and `lastmod` from last successful scrape

- [ ] **Add `rel=canonical`** to all pages — Self-referencing canonical on each page. For pages with `?start_date=` parameter, canonical points to the undated version. Add to the layout or as a `content_for :head` block per page.

- [ ] **Add BreadcrumbList JSON-LD** to all new pages:
  - Port pages: Home > [Territory] > [Port Name]
  - Beach pages: Home > [Territory] > [Port Name] > [Beach Name]

- [ ] **Internal cross-linking (R17):**
  - Port pages link to their beach pages in the day card or as a sidebar/footer section
  - Beach pages link back to their port page and the main schedule page
  - Main BVI page (`/`) links to `/tortola` port page
  - Main USVI page (`/usvi`) links to `/st-thomas` and `/st-croix`
  - Every page reachable within 2 clicks from any other page

- [ ] **Update `public/robots.txt`** — Add specific user-agent entries:
  ```
  User-agent: PerplexityBot
  Allow: /

  User-agent: GPTBot
  Allow: /

  User-agent: ClaudeBot
  Allow: /

  User-agent: *
  Allow: /
  Sitemap: https://bvicruiseshipschedule.com/sitemap.xml
  ```

- [ ] **Update Rack::Attack** — Ensure `start_date` throttle also covers the `date` param if used on new pages, or standardize on `start_date` everywhere. Keep the existing 10/min throttle for date parameter probing.

- [ ] **Add `rel=canonical` to existing pages** (`/` and `/usvi`) — Self-referencing canonical for the undated versions.

#### Acceptance Criteria
- [ ] `sitemap.xml` contains all 13 pages with correct URLs, priorities, and lastmod dates
- [ ] Every page has a self-referencing `rel=canonical` tag
- [ ] `?start_date=` variants have canonical pointing to undated version
- [ ] BreadcrumbList schema validates in Google's Rich Results Test
- [ ] All pages are reachable within 2 clicks from the homepage
- [ ] robots.txt includes PerplexityBot, GPTBot, ClaudeBot directives
- [ ] Rack::Attack throttles date parameter probing on new pages

---

### Phase 5: AI Search Optimization

**Goal:** FAQPage schema, direct-answer formatting, dateModified freshness.

#### Tasks

- [ ] **Add FAQPage JSON-LD** to all pages — 3-5 FAQs per page using real questions from Google's "People Also Ask" and Facebook group posts. Structure as a separate `<script type="application/ld+json">` block alongside the existing WebApplication/TouristAttraction schema.

  FAQs should use exact query language from GSC where possible (proven search demand), supplemented by PAA boxes:
  - `/tortola`: "What is the Tortola cruise ship schedule?" (GSC: "tortola cruise ship schedule", 10 imp), "Are there cruise ships in Tortola today?" (GSC: "cruise ships in tortola today", 4 imp), "What is the Road Town cruise ship schedule?" (GSC: 5 imp), "How far is Cane Garden Bay from the cruise port?"
  - `/virgin-gorda`: "What is the Virgin Gorda cruise ship schedule?" (GSC: 2 imp, pos 17.5), "Can cruise ship passengers visit The Baths from Virgin Gorda?", "How many cruise ships visit Spanish Town?"
  - `/the-baths`: "What is the best time to visit The Baths?" (GSC: "best time to visit the baths", pos **1.0**), "How crowded is The Baths when cruise ships are in port?", "Can cruise ship passengers visit The Baths?"
  - `/st-thomas`: "What is the cruise ship schedule for St. Thomas USVI?" (GSC: 1 imp, pos 75), "What is the port of St. Thomas cruise ship schedule?" (GSC: 1 imp, pos 85)
  - `/st-croix`: "What is the cruise ship schedule for St. Croix?" (GSC: 1 imp, pos 46)
  - `/magens-bay`: "Is Magens Bay crowded when cruise ships are in port?", "What is the best time to visit Magens Bay?"

- [ ] **Direct-answer lead sentences** — Each page section should lead with a specific, data-driven sentence. Examples:
  - Port page hero: "[N] cruise ships are scheduled to visit Road Town today, carrying approximately [X] passengers."
  - Beach page hero: "The Baths crowd risk is [HIGH/MODERATE/LOW] today — [N] ships in port with [X] total passengers."
  - FAQ answers should contain specific numbers from the database, not generic text.

- [ ] **`dateModified` in JSON-LD** — Set to the last successful scrape timestamp (`ScrapeLog.where(status: "success").order(scraped_at: :desc).first&.scraped_at`), not the deploy date. This signals freshness to both Google and AI assistants.

- [ ] **Verify FAQPage schema** validates in Google's Rich Results Test for at least 3 pages.

#### Acceptance Criteria
- [ ] FAQPage schema present on all 13 pages (2 existing + 11 new)
- [ ] FAQ answers contain dynamic data (ship counts, passenger numbers) where applicable
- [ ] `dateModified` reflects last scrape time, not build/deploy time
- [ ] Schema validates in Rich Results Test
- [ ] Page content leads with direct-answer sentences

---

### Phase 6: Shareability & Navigation

**Goal:** Shareable forecast URLs and navigation improvements.

#### Tasks

- [ ] **Date-linked URLs** — All new pages accept `?start_date=` parameter (same as existing pages) for sharing specific day views. The `parse_start_date` method from `ApplicationController` already handles this.

- [ ] **Past date handling** — When `start_date` is in the past and data exists, show the historical forecast with a prominent banner: "You're viewing a past forecast for [date]. [See today's forecast →]". Link to the undated page.

- [ ] **Navigation updates** — Keep the existing BVI/USVI tab navigation in the header. Add a subtle sub-navigation or "Explore" section on each page linking to related port and beach pages. Don't overcomplicate the header — breadcrumbs + contextual cross-links are sufficient for discoverability.

- [ ] **"Share" link** — Add a small "Share this forecast" link/button that copies the current page URL with `?start_date=[today]` to clipboard. Simple `navigator.clipboard.writeText()` with a Stimulus controller. No modal, no social share buttons — just copy to clipboard with a "Copied!" toast.

#### Acceptance Criteria
- [ ] `?start_date=2026-04-15` works on all pages, showing that day's forecast
- [ ] Past dates show historical data with a "see today" banner
- [ ] "Share" button copies URL with date parameter to clipboard
- [ ] Navigation between pages is intuitive (port <-> beach <-> schedule)

---

### Phase 7: Community Playbook (Non-Code)

**Goal:** Document where and how to seed the tool in communities.

#### Tasks

- [ ] **Write `docs/community-engagement-playbook.md`** covering:
  - **Facebook groups:** BVI travel group (the one ranking #6-8 in SERPs), St. Thomas group, St. John group. How to answer questions naturally with tool links. Example answers for common questions.
  - **Cruise Critic:** Tortola subforum (`boards.cruisecritic.com/forum/202-tortola/`), threads about avoiding crowds. Answer with specific data.
  - **TripAdvisor:** BVI and USVI forums. Same approach.
  - **Reddit:** r/Cruise, r/CaribbeanTravel — lowest priority, answer only existing threads, no self-promotion posts.
  - **Key rule:** Every post must genuinely answer the question first. The link is supplementary, not the point.

#### Acceptance Criteria
- [ ] Playbook doc exists with specific group URLs, example answers, and guidelines
- [ ] Tone matches Matt's authentic voice (charter brokerage, not marketing persona)

---

## System-Wide Impact

- **No schema changes** — all new pages use existing Port, Location, CruiseVisit, CrowdSnapshot models
- **No new background jobs** — data freshness depends on existing scraper schedule
- **Route namespace:** 12 new top-level routes. All are explicit named routes, no catch-all. No conflict risk with existing routes.
- **Performance:** Each new page runs 3 queries (port, visits, snapshots) — same as existing pages. No N+1 risk with `.includes(:port)` and `.includes(:crowd_threshold)`.
- **Sitemap growth:** 2 -> 14 URLs. Well within sitemap limits.
- **Layout changes:** Adding `rel=canonical` to `<head>` and breadcrumbs — affects all pages via layout.

## Dependencies & Prerequisites

- Existing scraper continues running and generating CrowdSnapshot data (no changes needed)
- Outreach campaign continues independently (more backlinks = faster ranking for new pages)
- Images needed for beaches without photos: Cane Garden Bay, Coki Beach, National Park Beaches, Rainbow Beach, Buck Island. Can use stock or AI-generated initially.

## Success Criteria (from origin)

- 14 indexable pages (up from 2), each targeting a distinct keyword cluster
- At least 3 pages ranking in top 10 within 90 days
- Organic traffic measurable in Ahrefs within 60 days
- Daily visitors from 30-50 to 150+ within 90 days
- At least one AI assistant cites the site for BVI cruise ship crowd queries

## Risk Analysis

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Duplicate content between `/` and `/tortola` | Medium | Medium | Different framing: `/` is multi-port overview, `/tortola` is single-port with logistics. Self-canonical on each. |
| Google treats new pages as thin content | Low | High | Pages have unique dynamic data per day, FAQ schema, and different keyword targeting. Not boilerplate. |
| Partial extraction breaks existing pages | Low | High | Visual regression test before and after refactor (Phase 1). |
| Missing images for some beach pages | Medium | Low | Use placeholder images initially, source real photos over time. |

## Sources & References

### Origin

- **Origin document:** [docs/brainstorms/2026-04-14-growth-and-dominance-requirements.md](docs/brainstorms/2026-04-14-growth-and-dominance-requirements.md) — Key decisions: tool pages not content, all 8 beach pages, AI optimization first-class, no new data sources.

### Internal References

- Controller pattern: `app/controllers/usvi_controller.rb` (data loading pattern to follow)
- View structure: `app/views/pages/home.html.erb` (partials to extract)
- Helper methods: `app/helpers/pages_helper.rb:75-84` (needs expansion)
- Models: `app/models/port.rb`, `app/models/location.rb` (slug constants)
- Sitemap: `app/controllers/sitemap_controller.rb` (append new URLs)
- Rack::Attack: `config/initializers/rack_attack.rb` (date param throttling)
- Existing robots.txt: `public/robots.txt` (add bot directives)
- Date parsing: `app/controllers/application_controller.rb` (`parse_start_date` method)

### Research

- Keyword data: Ahrefs keyword explorer (2026-04-14) — volumes and KD scores in origin document
- SERP analysis: Ahrefs SERP overview (2026-04-14) — competitor positions in origin document
- AI search optimization: `docs/ai-search-optimization-research.md`
- Community channels: `docs/community-channel-research.md`
- Link building (parallel effort): `docs/link-building-strategy.md`
