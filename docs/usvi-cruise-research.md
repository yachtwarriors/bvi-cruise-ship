# USVI Cruise Ship Tourism Research

*Researched: March 28, 2026*

---

## 1. St. Thomas — Charlotte Amalie Cruise Port

### Port Infrastructure
- **Two docks**: West Indian Company Dock (WICO/Havensight) with 3 berths, Crown Bay Dock with 2 berths = **5 berths total**
- Ships can also **anchor in Charlotte Amalie Harbor** and tender passengers ashore
- On peak days, **up to 6+ ships** can be in port simultaneously (dock + anchor)
- Typical busy day: 3-5 ships. Slow day: 0-2 ships. Peak season Wednesdays are heaviest.

### Annual Traffic (USVI-wide, St. Thomas dominates)
- **2024**: 1,770,922 cruise passengers across USVI (9.8% increase from 2023)
- **FY2024**: 506 cruise ship calls across USVI
- **FY2025 projected**: 595 scheduled calls (18% increase), ~11% passenger growth
- **Single-day record**: 4,606 visitors on Dec 28, 2024
- **Record week**: 24,000+ arrivals in one week (Dec 2024)
- St. Thomas receives the vast majority — estimated 1.5M+ cruise visitors per year on its own

### Top Cruise Excursion Destinations from St. Thomas
1. **Magens Bay Beach** — #1 destination, National Geographic top-10 beach. Gets very crowded on ship days. Nearly all cruise visitors head here. $5 entrance fee.
2. **St. John day trip** (ferry from Red Hook to Cruz Bay) — Trunk Bay, Honeymoon Beach. Major overflow destination.
3. **Skyride to Paradise Point** — aerial tramway 700ft up, panoramic harbor views
4. **Charlotte Amalie shopping/walking tour** — Danish colonial architecture, 99 Steps, Blackbeard's Castle
5. **Sapphire Beach** — good snorkeling, typically less crowded than Magens Bay
6. **Catamaran/sailing excursions** — snorkel trips to various coves
7. **Food tours** — conch fritters, johnnycakes, Caribbean lobster
8. **Coral World Ocean Park** — marine attraction on the east end
9. **Lindqvist Beach / Brewer's Bay** — less crowded alternatives for those who venture further

### Crowding Pattern
- Peak crowds at Magens Bay and popular spots from ~10am-2:30pm
- Arrive before 9:30am or after 2:30pm to avoid worst crowds
- Multi-ship days (3+) create significant congestion island-wide

---

## 2. St. Croix — Frederiksted Cruise Port

### Port Infrastructure
- **One pier**: Ann E. Abramson Pier in Frederiksted (west side of island)
- **2 berths** — can accommodate 2 ships simultaneously
- Much smaller operation than Charlotte Amalie

### Annual Traffic
- **FY2024**: ~67 cruise ship calls (vs 400+ for St. Thomas)
- **FY2025 projected**: ~101 calls (85% increase year-over-year!) — biggest growth in USVI
- Predominantly **Royal Caribbean** ships (Jewel of the Seas, Adventure of the Seas, Radiance of the Seas)
- Typical: 1-2 ships max on any given day
- Ships arrive ~7-8am, depart ~5-6pm (9-11 hour port visits)

### Crowd-Impacted Beaches & Attractions

**HIGH IMPACT on cruise days:**
- **Rainbow Beach** — closest beach to Frederiksted pier, small beach that gets packed on ship days. Walking distance from dock.
- **Frederiksted town/waterfront** — lively with music, dancing, vendors on cruise days. Beach bars packed.
- **Buck Island** (excursion boats) — America's only underwater national monument. 800-acre uninhabited island. Snorkel trips are THE signature St. Croix cruise excursion. Boat tours from Christiansted fill up fast on cruise days.

**MODERATE IMPACT:**
- **Cane Bay** — north shore, popular snorkel/dive spot. Gets crowded on cruise days. Has the famous "Cane Bay Wall" (600ft offshore). Three beach bars, scuba shops. Cane Bay Dive Shop does heavy cruise ship tour business.
- **Christiansted town** — east side of island, ~17 miles from Frederiksted. Gets some overflow but distance helps.

**LOWER IMPACT (further from port):**
- **Point Udall** — easternmost point of the US. Scenic viewpoint. Isaac Bay is nearby (accessible by hike). Distance from Frederiksted limits cruise traffic.
- **Carambola Beach** — resort area, less cruise traffic
- **East End beaches** (Divi Resort area, Buccaneer Hotel) — alternatives locals use to avoid cruise crowds

### Crowd Timing
- Cruise passengers typically head back to ships mid-afternoon
- Beaches clear up significantly by 2-3pm
- Frederiksted itself is dead on non-cruise days, lively on cruise days

---

## 3. St. John — No Cruise Port (Overflow from St. Thomas)

### How Cruise Tourists Reach St. John
- **No cruise dock** — some very small ships (few hundred passengers) anchor off Cruz Bay and tender ashore
- Main source: **St. Thomas overflow** via ferry from Red Hook (~20 min, $8.15 each way)
- Cruise lines sell St. John shore excursions directly (Carnival, Disney, etc.)
- When 20,000+ cruise passengers visit St. Thomas in a day, "a good amount" head to St. John
- Over 2 million people visit St. John annually (all sources, not just cruise)

### Crowd-Impacted Locations

**HIGHEST IMPACT:**
- **Trunk Bay** — #1 cruise excursion destination on St. John. Famous underwater snorkel trail. $5 NPS entrance fee. Gets very crowded afternoons on big St. Thomas ship days. Most cruise excursions go here.
- **Cruz Bay town** — ferry arrival point, compact area with shops/restaurants. Gets congested when multiple ships are in St. Thomas.

**MODERATE IMPACT:**
- **Honeymoon Beach** — close to Cruz Bay, accessible by water taxi from Cruz Bay. Popular cruise excursion stop. Feels more secluded than Trunk Bay.
- **Caneel Bay area** — near Cruz Bay, some tour traffic

**LOWER IMPACT (cruise tourists rarely reach these):**
- **Maho Bay** — quieter alternative to Trunk Bay, known for sea turtles. Less cruise traffic.
- **Cinnamon Bay** — another quieter NPS beach, good for escaping Trunk Bay crowds
- **Salt Pond Bay** — east end, rarely visited by cruise tourists (too far)
- **East End beaches** — recommended by locals on heavy cruise days

### Key Insight
The impact on St. John scales with St. Thomas ship count. A 1-2 ship day in Charlotte Amalie = minimal St. John impact. A 5-6 ship day = noticeable crowding at Trunk Bay and Cruz Bay.

---

## 4. Data Sources for USVI Cruise Schedules

### Official Sources

| Source | URL | Coverage | Notes |
|--------|-----|----------|-------|
| **VIPA** (Virgin Islands Port Authority) | viport.com/schedule-cruise-ports | St. Thomas, St. John, St. Croix | FY2026 schedule (Oct 2025-Sep 2026). Wix-based site, JS-heavy, hard to scrape. Updated as of Feb 11, 2026. |
| **WICO** (West Indian Company Limited) | wico.vi | Havensight dock only (St. Thomas) | Separate from VIPA. Covers only one of the two St. Thomas docks. |

### Third-Party Aggregators

| Source | URL | Coverage | Data Fields | Scrapability |
|--------|-----|----------|-------------|-------------|
| **Crew Center** | crew-center.com/st-thomas-charlotte-amalie-usvi-cruise-ship-schedule | St. Thomas + St. Croix (separate pages) | Ship name, cruise line, passenger capacity, date, arrival/departure time | HTML tables. Same format as BVI schedule you already scrape. **Best bet.** |
| **CruiseDig** | cruisedig.com/ports/st-thomas-us-virgin-islands | St. Thomas + St. Croix (separate pages) | Ship name, cruise line, passenger capacity, date, time | 2025-2027 data. Created by same team as Crew Center. Has custom data services. |
| **CruiseMapper** | cruisemapper.com/ports/st-thomas-island-usvi-port-604 | St. Thomas + St. Croix | Schedule + port info | Monthly schedule view |
| **VINow** | vinow.com/cruise/ship-schedule/ | All 3 islands combined | Ship name, port (WICO/Crown Bay/St. Croix/Cruz Bay), capacity | Most recommended by locals. 403'd on fetch — may need browser. |
| **CruiseTimetables** | cruisetimetables.com/st-thomas-us-virgin-islands-cruise-ship-schedule.html | St. Thomas + St. Croix | Basic schedule | Simple format |
| **stcroixtourism.com** | stcroixtourism.com/st_croix_cruise_ship.htm | St. Croix only | Schedule + port info | Local tourism site |

### Crew Center URL Patterns (confirmed working)
- St. Thomas: `crew-center.com/st-thomas-charlotte-amalie-usvi-cruise-ship-schedule`
- St. Croix: `crew-center.com/st-croix-usvi-cruise-ship-schedule`
- (These follow the same pattern as your existing BVI scraper targets)

### CruiseDig URL Patterns
- St. Thomas: `cruisedig.com/ports/st-thomas-us-virgin-islands`
- St. Croix: `cruisedig.com/ports/st-croix-us-virgin-islands`
- Both have `/departures` subpages too

### Key Observations for Scraping
1. **Crew Center** is the most promising — same format you already scrape for BVI. Has both Charlotte Amalie and Frederiksted. Includes passenger capacity per ship.
2. **CruiseDig** was created by the Crew Center team. Richer data but heavier JS (301 redirects on direct curl).
3. **VIPA** is the official source but built on Wix — very JS-heavy, data not in initial HTML.
4. **VINow** is the go-to local source but returned 403 on fetch attempt.
5. St. John doesn't have its own schedule page on most sites since it rarely gets direct ship visits.

---

## Summary Comparison

| Metric | St. Thomas (Charlotte Amalie) | St. Croix (Frederiksted) | St. John (Cruz Bay) |
|--------|-------------------------------|--------------------------|---------------------|
| **Berths** | 5 (+ harbor anchorage) | 2 | 0 (anchor only) |
| **Ships/day typical** | 2-5 | 0-2 | 0-1 (small ships) |
| **Ships/day peak** | 6+ | 2 | Overflow from STT |
| **Annual calls (FY24)** | ~440 | ~67 | Handful |
| **Annual calls (FY25 proj)** | ~494 | ~101 | N/A |
| **Main cruise lines** | All major lines | Primarily Royal Caribbean | Small luxury lines |
| **Top crowd spot** | Magens Bay Beach | Rainbow Beach / Buck Island | Trunk Bay |
| **Crowd severity** | Very High | Moderate | High (on big STT days) |
