# BVI Cruise Ship Schedule Sources Research

**Date**: March 27, 2026

## 1. Official BVI Government / Port Authority Source

### BVI Ports Authority (bviports.org)
- **URL**: https://bviports.org/services/cruise
- **Status**: The BVIPA website has a "Cruise Schedule" section but it does NOT display actual schedule data on the page. It's essentially a placeholder/marketing page.
- **Data available**: None directly on site. Directs users elsewhere.

### PortCall.com BVI (bvi.portcall.com)
- **URL**: https://bvi.portcall.com/
- **Status**: This is the BVIPA's official port community scheduling system, implemented by the Ports Authority. It's a JavaScript-heavy web app that coordinates scheduling between the port, pilots, and agents.
- **Data available**: Live arrival/departure schedules. The app loads data dynamically so content isn't easily scraped from static HTML. Would need to inspect the API endpoints it calls.
- **Key detail**: This is the canonical source -- local tourism and transportation vendors use it. News article confirms BVIPA rolled it out as their official online booking system (https://www.virginislandsnewsonline.com/en/news/bvipa-rolling-out-new-portcall-online-booking-system).

### BVI Beacon (bvibeacon.com)
- **URL**: http://www.bvibeacon.com/cruise-ship-schedule/
- **Status**: Returns 403 forbidden. May be behind paywall or discontinued.

---

## 2. Third-Party Schedule Websites

### Crew Center (crew-center.com)
- **URL**: http://crew-center.com/road-town-tortola-bvi-cruise-ship-schedule
- **Data fields**: Ship name, cruise line, passenger capacity (double occupancy), arrival date+time, departure date+time
- **Example data**:
  - Marella Discovery 2 | Marella Cruises | 2,198 pax | 28 Mar 2026 08:00 | 28 Mar 2026 18:00
  - Norwegian Epic | NCL | 5,074 pax | 30 Mar 2026 08:00 | 30 Mar 2026 17:00
  - Disney Treasure | Disney | 3,466 pax | 01 Apr 2026 08:15 | 01 Apr 2026 14:00
- **BVI ports covered**: Road Town Tortola, Virgin Gorda/Spanish Town, Jost Van Dyke, Norman Island (separate pages for each)
- **Strengths**: Best data richness -- has passenger capacity AND both arrival/departure times. Covers multiple BVI ports.

### CruiseDig (cruisedig.com)
- **URL**: https://cruisedig.com/ports/tortola-british-virgin-islands/arrivals
- **Data fields**: Ship name, cruise line, passenger capacity, arrival date+time
- **Missing**: Departure times not shown on main arrivals page
- **BVI ports covered**: Tortola, Virgin Gorda, Jost Van Dyke (separate port pages)
- **Example data**:
  - Marella Discovery 2 | Marella Cruises | 2,198 pax | 28 Mar 2026 08:00
  - Norwegian Sky | NCL | 2,405 pax | 29 Mar 2026 07:00
  - Disney Treasure | Disney | 3,466 pax | 01 Apr 2026 08:15

### CruiseMapper (cruisemapper.com)
- **URL**: https://www.cruisemapper.com/ports/tortola-island-bvi-port-35
- **Data fields**: Day/date, ship name (with cruise line icon), arrival time, departure time
- **Missing**: Passenger capacity NOT in the schedule table
- **BVI ports covered**: Tortola (port-35), Virgin Gorda (port-983), Jost Van Dyke (port-1120), Norman Island (port-1968)
- **Example data**:
  - 1 March 2026 Sunday | Norwegian Sky | 07:00 | 14:00
  - 2 March 2026 Monday | Norwegian Epic | 08:00 | 17:00
- **Port infrastructure notes**: Mentions Road Town Jetty, Soper's Hole Marina, 2-ship pier capacity, tender when >2 ships

### CruiseTimetables (cruisetimetables.com)
- **URL**: https://www.cruisetimetables.com/tortola-british-virgin-islands-cruise-ship-schedule.html
- **Main page data**: Ship names, dates, port locations ("Road Town Cruise Pier" and "Soper's Hole tender pier"), timezone (AST)
- **Day detail pages** (e.g., tortolabritishvirginislandsschedule-28mar2026.html): Ship name, cruise line, arrival time, departure time, passenger capacity
- **Key differentiator**: ONLY source that explicitly labels port location as "Road Town Cruise Pier" vs "Soper's Hole tender pier" on the main schedule page
- **BVI coverage**: Tortola and Virgin Gorda (separate pages)

### WhatsInPort (whatsinport.com)
- **URL**: https://www.whatsinport.com/Roadtown-Tortola.htm
- **Status**: Links out to bvi.portcall.com for actual schedule data
- **Useful for**: General port info, not schedule data itself

### VesselFinder (vesselfinder.com)
- **URL**: https://www.vesselfinder.com/ports/VGRAD001
- **Data**: Real-time AIS tracking of arrivals, departures, and ships currently in port
- **Use case**: Real-time verification rather than forward-looking schedule

---

## 3. Data Fields Comparison Matrix

| Source | Ship Name | Date | Arrival Time | Departure Time | Pax Capacity | Port/Berth Location | Cruise Line |
|--------|-----------|------|-------------|---------------|-------------|-------------------|-------------|
| PortCall.com (official) | ? | ? | ? | ? | ? | ? | ? |
| Crew Center | Yes | Yes | Yes | Yes | Yes | No | Yes |
| CruiseDig | Yes | Yes | Yes | No (arrivals) | Yes | No | Yes |
| CruiseMapper | Yes | Yes | Yes | Yes | No | No | Yes (icon) |
| CruiseTimetables (main) | Yes | Yes | No | No | No | Yes* | No |
| CruiseTimetables (day) | Yes | Yes | Yes | Yes | Yes | No | Yes |

*CruiseTimetables is the only source that distinguishes "Road Town Cruise Pier" vs "Soper's Hole tender pier"

---

## 4. BVI Port/Location Coverage

### Tortola - Road Town (Primary cruise port)
- **All sources cover this**
- Pier capacity: 2 large ships (up to 180,000 GT each, expanded 2015)
- Overflow: 3rd+ ship anchors in bay, passengers tender to Road Town Jetty
- Small/luxury ships sometimes use Soper's Hole Marina (West End, ~5 miles west)
- 2023 data: 232 cruise calls at Tortola pier

### Virgin Gorda - Spanish Town (Tender port)
- **Covered by**: CruiseMapper, CruiseTimetables, CruiseDig, Crew Center
- Ships anchor offshore, tender to Virgin Gorda Yacht Harbour
- 2023 data: ~38 cruise calls (roughly 6:1 ratio vs Tortola)
- Visitors go to The Baths from here
- Example ships: MSC Explora 1, Wind Surf, Star Clipper (smaller/luxury vessels)

### Jost Van Dyke (Tender port - small ships only)
- **Covered by**: CruiseMapper (port-1120), CruiseDig, Crew Center
- Ships anchor and tender to White Bay or Great Harbour
- **No source distinguishes between White Bay vs Great Harbour landing**
- Primarily luxury/small ship operators: Windstar (Wind Surf, 404 pax), Crystal (1,040 pax), Seabourn (638 pax), Star Clippers
- Passenger capacity range: 112 to ~1,473

### Norman Island (Anchor port - small ships only)
- **Covered by**: CruiseMapper (port-1968), Crew Center
- Ships anchor at The Bight (western side harbor)
- Small luxury vessels and superyachts only: Star Clippers, Emerald Cruises, Ponant, SeaDream
- ~7 visits per month in high season

---

## 5. Existing Crowd Prediction / Charter Planning Tools

### BVI Charter Chat (bvicharterchat.com)
- **URL**: https://www.bvicharterchat.com/cruise-ship-schedule
- **What it does**: Shows "who's in port now" and helps find quietest days to visit popular attractions
- **Limitation**: Built on Wix, content loads dynamically. Could not extract actual data. Does NOT appear to do crowd prediction -- just shows the schedule.

### No dedicated crowd prediction tool exists
- Searched extensively. No app or website combines cruise ship schedule data with crowd predictions for specific BVI locations (The Baths, White Bay, Soggy Dollar, The Caves, etc.)
- Charter company blogs give generic timing advice ("arrive before 10am at The Baths") but nothing data-driven
- This is a clear gap in the market

---

## 6. API & Programmatic Access Research (March 27, 2026)

### Summary: No free cruise schedule APIs exist. Scraping is the realistic path.

---

### 1. CruiseMapper (cruisemapper.com)
- **Public API?** NO. CruiseMapper does not offer a public REST API for schedule data.
- **Workaround**: Two Apify scrapers exist:
  - [Cruisemapper Cruise Scraper](https://apify.com/louisdeconinck/cruisemapper-cruise-scraper/api) by louisdeconinck
  - [Cruisemapper Cruises Scraper](https://apify.com/vulnv/cruisemapper-cruises-scraper) by vulnv
- **Apify cost**: Free tier = $5/month in credits (~enough for light scraping). Free users limited to 5 results per run. Paid plans start at $49/month.
- **Data extracted**: Ship names, itineraries, departure dates, prices. Port schedule data available via port pages.
- **Verdict**: Could use Apify scraper on free tier for periodic BVI port page scrapes, but limited. Better to scrape directly.

### 2. Crew Center (crew-center.com)
- **Public API?** NO. No API, no developer docs, no data export.
- **Scrapability**: EXCELLENT. Server-rendered HTML with simple `<table>` structure. Two tables (arrivals/departures) with plain `<td>` cells containing ship name, cruise line, passenger capacity, and date/time. Easiest site to scrape.
- **Verdict**: Best scraping target. Simple HTML tables, richest data fields (ship, line, pax, arrival time, departure time), covers 4 BVI ports.

### 3. CruiseTimetables (cruisetimetables.com)
- **Public API?** NO. No API, no developer docs, no data export.
- **Scrapability**: GOOD. Server-rendered HTML. Main page has month/day link structure. Day detail pages (e.g., `tortolabritishvirginislandsschedule-28mar2026.html`) contain full data. Would need to scrape individual day pages for complete data.
- **URL pattern**: Predictable: `tortolabritishvirginislandsschedule-[DD][mon][YYYY].html`
- **Verdict**: Good secondary source. Unique berth location data (Road Town Cruise Pier vs Soper's Hole). Requires scraping ~30 day-pages per month.

### 4. PortCall.com / bvi.portcall.com
- **Public API?** NO. PortCall.com's marketing site mentions no API or developer docs. The platform is a SaaS for ports/pilots/agents -- not a data provider.
- **bvi.portcall.com**: JavaScript-heavy SPA. Schedule data loaded dynamically via internal API calls. Would need browser dev tools to reverse-engineer the endpoints.
- **Other PortCall instances**: hawaii.portcall.com, maine.portcall.com exist (same platform). None expose public APIs.
- **Verdict**: Could potentially reverse-engineer the internal JSON API that the SPA calls, but risky -- endpoints could change without notice. Lower priority.

### 5. BVI Ports Authority / BVI Tourism Board
- **Machine-readable data?** NO. No CSV, JSON, iCal, or RSS feeds found anywhere.
- **bviports.org**: Cruise schedule page is a placeholder with no actual data.
- **bviplatinum.com/cruiseschedule.php**: Third-party site (Platinum Media Group) that aggregates BVI cruise data. Shows ship name, arrival/departure times, guest count, and port/pier location. Formatted as HTML lists (not tables), but parseable.
- **Verdict**: No official data feeds exist. BVI Platinum is an interesting additional source with pier-level detail.

### 6. AIS/Maritime Tracking APIs (MarineTraffic, VesselFinder, FleetMon, Datalastic)

These are AIS-based vessel tracking services. They track where ships ARE, not where they're SCHEDULED to be.

| Service | Port Calls API? | Future Schedule? | Pricing | BVI Coverage |
|---------|----------------|-----------------|---------|-------------|
| **MarineTraffic** (now Kpler) | Yes (historical) | Expected Arrivals endpoint exists | $10-100/mo base plans; API pricing requires contact. Stopped pay-per-credit Jan 2025. | Yes (AIS-based) |
| **VesselFinder** | Yes (2 credits/record) | ExpectedArrivals separate endpoint | Credit-based, no published credit prices | Yes (AIS-based) |
| **FleetMon** (now Kpler) | Yes (Port Calls per Port) | ETA via Voyage Planning | No published pricing, contact required | Yes (AIS-based) |
| **Datalastic** | Yes | ETA and destination | Trial: EUR 9; Starter: EUR 199/mo (20K requests); Unlimited: EUR 679/mo | Yes (AIS-based) |

**Key limitation**: These give you real-time/near-real-time ship positions and historical port calls. They do NOT give you the forward-looking cruise line deployment schedules (which ship visits which port 3 months from now). For crowd prediction, you need SCHEDULE data, not AIS tracking.

**One potential use**: VesselFinder or MarineTraffic "Expected Arrivals" could verify/update schedule data in near-real-time (e.g., confirm a ship is actually en route, detect cancellations or delays).

### 7. Cruise Booking APIs (Widgety, CruiseHost/CRUISE-API, Traveltek)

These are B2B booking/pricing APIs for travel agents. They have itinerary data but are designed for booking cruise cabins, not extracting port schedules.

| Service | Port Schedule Data? | Pricing | Practicality |
|---------|-------------------|---------|-------------|
| **Widgety** | Itineraries include ports + day timings "if provided by cruise line" | Contact sales; no public pricing | Overkill -- designed for travel agents selling cruises |
| **CruiseHost (cruise-api.com)** | 28 live APIs, 19 cruise lines | Contact sales; returns 403 on homepage | Enterprise booking platform, not data extraction |
| **Traveltek Cruise Connect** | 30,000+ itineraries, 27 cruise lines | Contact sales | Same -- booking engine, not schedule API |

**Verdict**: These APIs technically contain port schedule data buried in itinerary records, but they're designed for booking engines, likely expensive, and require commercial relationships. Not practical for a crowd prediction tool.

---

### BOTTOM LINE: Scraping Strategy

No free or affordable API provides BVI cruise ship schedule data. The realistic approach is web scraping, and the good news is the best sources are easy to scrape.

**Recommended scraping stack (in priority order):**

1. **Crew Center** (PRIMARY) -- Simple HTML tables, all data fields, 4 BVI ports
   - Scrape frequency: Weekly (schedules don't change often)
   - Pages to scrape: 4 (Road Town, Virgin Gorda, JVD, Norman Island)
   - Difficulty: Easy (static HTML tables)

2. **CruiseTimetables day pages** (SECONDARY) -- Unique berth location data
   - Scrape frequency: Weekly
   - Pages to scrape: ~120/month (30 days x 4 ports, but only Tortola + Virgin Gorda available)
   - Difficulty: Easy (static HTML, predictable URLs)

3. **BVI Platinum** (SUPPLEMENTARY) -- Has pier/berth detail + guest counts
   - Scrape frequency: Weekly
   - Pages to scrape: 1
   - Difficulty: Easy-Medium (HTML lists, not tables)

4. **bvi.portcall.com** (VERIFICATION) -- Official source, reverse-engineer JS API
   - Scrape frequency: As needed for verification
   - Pages to scrape: Inspect network requests, call internal API
   - Difficulty: Medium-Hard (SPA, need to discover endpoints)

**What NOT to bother with:**
- MarineTraffic/VesselFinder/FleetMon: Too expensive for what you get, wrong data type (AIS vs schedule)
- Widgety/CruiseHost/Traveltek: Enterprise booking APIs, overkill and expensive
- CruiseMapper: No API, and Crew Center has better data anyway

---

## 7. Key Insights for Building a Crowd Prediction Tool

### Data sourcing strategy (ranked by value):
1. **Crew Center** -- richest data (ship name, line, pax capacity, arrival/departure times). Covers 4 BVI ports.
2. **CruiseTimetables day pages** -- also has full data including pax capacity + arrival/departure. Unique: labels Road Town vs Soper's Hole.
3. **CruiseMapper** -- good for arrival/departure times but missing pax counts.
4. **CruiseDig** -- good pax data but missing departure times on arrivals view.
5. **PortCall.com (bvi.portcall.com)** -- official source, JS-heavy app, would need to reverse-engineer API.

### What the tool would uniquely provide:
- Combine schedule data from multiple BVI ports (Road Town, Virgin Gorda, Jost Van Dyke, Norman Island)
- Map cruise ship arrivals to SPECIFIC locations they impact:
  - Road Town ships --> impact Road Town shopping, Cane Garden Bay (taxi tours)
  - Virgin Gorda ships --> impact The Baths, Spring Bay, Spanish Town
  - Jost Van Dyke ships --> impact White Bay (Soggy Dollar), Great Harbour (Foxy's)
  - Norman Island ships --> impact The Bight, The Caves, The Indians
- Layer passenger count data to predict crowd INTENSITY (5,000 pax Norwegian Epic vs 312 pax Star Pride)
- Factor in arrival/departure windows to suggest optimal timing ("The Baths clear out after 3pm when tenders return")
- Account for days with MULTIPLE ships in port (heaviest crowd days)

### Missing data that would need local knowledge:
- Which shore excursions go where (e.g., what % of Road Town cruise passengers take The Baths excursion via ferry?)
- Tender schedules for anchor ports (when do passengers actually arrive/depart the beach?)
- Whether specific ships dock at Road Town pier vs Soper's Hole (only CruiseTimetables has this, inconsistently)
