# USVI Expansion Plan

**Date:** 2026-03-30

## Data Model

**No Territory model needed.** Add `territory` string (`"bvi"` / `"usvi"`) to `ports` and `locations`. Add `port_id` to `locations` to link which port feeds which location.

### New Ports

| name | slug | territory |
|------|------|-----------|
| Charlotte Amalie, St. Thomas | charlotte-amalie | usvi |
| Frederiksted, St. Croix | frederiksted | usvi |

### New Locations

| name | slug | territory | fed by |
|------|------|-----------|--------|
| Magens Bay | magens-bay | usvi | charlotte-amalie |
| Coki Beach | coki-beach | usvi | charlotte-amalie |
| National Park Beaches, St. John | national-park-beaches | usvi | charlotte-amalie |
| Rainbow Beach | rainbow-beach | usvi | frederiksted |
| Buck Island | buck-island | usvi | frederiksted |

### Crowd Thresholds (starting estimates)

| Location | green_max | yellow_max | Analogue |
|----------|-----------|------------|----------|
| Magens Bay | 300 | 800 | Cane Garden Bay |
| Coki Beach | 150 | 400 | Smaller beach |
| National Park Beaches | 200 | 600 | The Baths |
| Rainbow Beach | 100 | 300 | Small, at pier |
| Buck Island | 80 | 250 | Excursion-limited |

## Crowd Calculation

Extend `CrowdCalculationService` with USVI location cases:

| Location | Source Port | Pax % | Transit Time | Earliest |
|----------|-----------|-------|-------------|----------|
| Magens Bay | Charlotte Amalie | 25% | 30min | 8:30am |
| Coki Beach | Charlotte Amalie | 20% | 30min | 8:30am |
| National Park Beaches | Charlotte Amalie | 15% | 90min | 9:00am |
| Rainbow Beach | Frederiksted | 40% | 5min | 8:00am |
| Buck Island | Frederiksted | 15% | 60min | 9:00am |

## Scraper

Add Charlotte Amalie and Frederiksted to `CrewCenterScraperService::PORT_PATHS`. Verify URLs first:
- `/charlotte-amalie-st-thomas-usvi-cruise-ship-schedule` (needs confirmation)
- `/frederiksted-st-croix-usvi-cruise-ship-schedule` (needs confirmation)

## Routes & Controller

```ruby
get "/usvi", to: "usvi#show", as: :usvi
get "/us-virgin-islands-cruise-ship-schedule", to: redirect("/usvi", status: 301)
get "/st-thomas-cruise-ship-schedule", to: redirect("/usvi", status: 301)
```

`UsviController#show` mirrors `PagesController#home` but scopes to USVI ports/locations. Groups data by port for two-section layout.

## USVI Page Layout

Each day card has two port sub-sections:

```
┌─────────────────────────────────────────┐
│ Mon Mar 30, 2026                        │
│                                         │
│ ── St. Thomas (Charlotte Amalie) ─────  │
│ 2 ships, 8,400 guests                   │
│ Oasis of the Seas, Celebrity Beyond     │
│                                         │
│ 🏖️ Magens Bay              [Moderate]  │
│ [7a][8a][9a]...hourly timeline          │
│                                         │
│ 🐠 Coki Beach              [Moderate]  │
│ [7a][8a][9a]...                         │
│                                         │
│ 🏝️ National Park Beaches    [Low Risk] │
│ [7a][8a][9a]...                         │
│                                         │
│ ── St. Croix (Frederiksted) ─────────  │
│ No ships scheduled                      │
│                                         │
│ [YW CTA if yellow/red]                  │
└─────────────────────────────────────────┘
```

## Shared Partials to Extract

- `shared/_timeline_legend.html.erb` — green/yellow/red explainer
- `shared/_hourly_timeline.html.erb` — 11-cell hour grid
- `shared/_yacht_warriors_cta.html.erb` — contextual CTA
- `shared/_charter_protect_footer.html.erb` — footer link

Refactor BVI homepage to use the same partials.

## Cross-Linking

- BVI homepage: banner "Also visiting the USVI? → USVI Schedule"
- USVI page: banner "Also visiting the BVI? → BVI Schedule"
- Header nav: "BVI" / "USVI" links with active state

## SEO

- USVI-specific meta title, description, keywords
- JSON-LD with TouristAttraction entries for all 5 locations
- Sitemap entry for `/usvi`
- 301 redirects for long-tail URLs

## Daily Email

Single email covers both territories with a section divider. USVI section shows St. Thomas and St. Croix sub-sections. Subject line changes to "Cruise Crowd Report" (drops "BVI" prefix).

## Implementation Sequence

### Phase 1: Data foundation
1. Migration: `territory` on ports/locations, `port_id` on locations
2. Seeds: USVI ports, locations, thresholds, AppConfig entries
3. Model updates: constants, scopes, `belongs_to :port`

### Phase 2: Backend logic
4. Extend CrowdCalculationService with USVI cases
5. Add USVI ports to scraper (after confirming Crew Center URLs)
6. Run scraper, verify data flows

### Phase 3: USVI page
7. Extract shared partials from BVI homepage
8. Refactor BVI homepage to use partials
9. Create UsviController + route
10. Create USVI view with two-port-section layout
11. Cross-linking banners

### Phase 4: SEO & email
12. Meta tags, JSON-LD, sitemap
13. Header nav update
14. Email mailer USVI section
15. SEO redirect routes

### Phase 5: Polish
16. Mobile responsive testing
17. Threshold tuning after real data

## Before Starting: Verify Crew Center URLs

```bash
curl -s -o /dev/null -w "%{http_code}" "https://crew-center.com/charlotte-amalie-st-thomas-usvi-cruise-ship-schedule"
curl -s -o /dev/null -w "%{http_code}" "https://crew-center.com/frederiksted-st-croix-usvi-cruise-ship-schedule"
```

If these 404, search Crew Center for the correct paths before proceeding.
