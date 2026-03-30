---
date: 2026-03-30
topic: usvi-expansion
---

# USVI Cruise Ship Schedule & Crowd Tracker

## Problem Frame
Charter guests and tourists visiting the USVI face the same cruise crowd problem as the BVI. The site already has the infrastructure — scraping, crowd calculation, hourly timelines. Users have requested USVI coverage. Adding it expands the site's audience and SEO footprint without a separate product.

## Requirements
- R1. Dedicated USVI page at `/usvi` (or similar SEO-friendly URL) with its own meta tags, JSON-LD, and crowd tracker
- R2. Homepage stays BVI-focused with a prominent callout linking to the USVI page
- R3. Two independent port sections on the USVI page — St. Thomas and St. Croix — clearly separated (not lumped together)
- R4. St. Thomas port (Charlotte Amalie) tracks crowd risk at: Magens Bay, Coki Beach, National Park Beaches (Trunk/Maho/Cinnamon grouped as one)
- R5. St. Croix port (Frederiksted) tracks crowd risk at: Rainbow Beach, Buck Island
- R6. Crowd calculation logic mirrors BVI patterns:
  - Magens Bay & Coki Beach = Cane Garden Bay logic (taxi ride from port, crowds arrive quickly)
  - National Park Beaches (St. John) = The Baths logic (excursion boat, ~90min delay)
  - Rainbow Beach = immediate (right at the pier)
  - Buck Island = ~1 hour delay (excursion boats)
- R7. Same 7-day rolling view, hourly timeline (7am-5pm), green/yellow/red system
- R8. Scrape Charlotte Amalie and Frederiksted schedules from Crew Center (same format as BVI)
- R9. USVI page has its own navigation (prev/next week, date picker) independent of BVI
- R10. Cross-link between BVI and USVI pages in both directions
- R11. YW and CharterProtect CTAs appear on USVI page same as BVI
- R12. Daily email alerts include USVI data if user sets alert dates (single email covering both territories, or user picks which)

## Success Criteria
- USVI page ranks for "USVI cruise ship schedule", "St. Thomas cruise ship schedule", "Charlotte Amalie cruise ships"
- Crowd predictions feel accurate to someone who knows the islands
- The two port sections are clearly distinct — user understands St. Thomas ships don't affect St. Croix

## Scope Boundaries
- No separate website or subdomain — single app, new page
- No USVI-specific admin thresholds yet (use sensible defaults, tune later)
- No historical data backfill for USVI (start collecting now)
- No changes to BVI homepage functionality

## Key Decisions
- **Grouped St. John beaches**: Trunk/Maho/Cinnamon shown as one "National Park Beaches, St. John" location rather than three separate items. Can't meaningfully distinguish crowd levels between them.
- **Two-section layout**: USVI page shows St. Thomas and St. Croix as visually distinct sections, each with their own ship list and crowd timelines. Not intermingled.
- **Crew Center as data source**: Same scraper pattern as BVI. Charlotte Amalie and Frederiksted pages confirmed available.

## Dependencies / Assumptions
- Crew Center has Charlotte Amalie and Frederiksted schedule pages in the same table format
- Crowd thresholds for USVI locations need to be estimated (no historical data yet)

## Outstanding Questions

### Deferred to Planning
- [Affects R1][Technical] URL structure: `/usvi`, `/us-virgin-islands`, `/st-thomas-cruise-ship-schedule`? SEO research needed.
- [Affects R8][Needs research] Confirm exact Crew Center URLs for Charlotte Amalie and Frederiksted and verify table format matches existing scraper.
- [Affects R6][Technical] Specific threshold numbers for each USVI location (green_max, yellow_max). Start with BVI analogues and tune.
- [Affects R12][User decision] Should daily email cover both BVI + USVI, or let users pick territory?
- [Affects R3][Technical] How to model two port sections on one page — separate day cards per port, or one day card with port sub-sections?

## Next Steps
→ `/ce:plan` for structured implementation planning
