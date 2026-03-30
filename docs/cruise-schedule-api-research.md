# Cruise Ship Schedule API Research

**Date**: March 28, 2026

## Executive Summary

**No single API exists that provides cruise ship port schedules (ship name + arrival/departure times + passenger capacity) for specific Caribbean ports at a reasonable price.** The market splits into two categories:

1. **AIS/Maritime tracking APIs** -- These track vessel positions via AIS transponders and can derive port calls (arrival/departure times), but they don't know passenger capacity or future schedules. They're designed for cargo/logistics, not cruise tourism. Cheapest useful option: **VesselFinder at ~EUR 330/year** for historical port call data.

2. **Cruise booking/content APIs** -- These have itineraries, ship details, and port visit schedules from cruise lines, but they're designed for travel agents selling cruises, not for port-side crowd tracking. Most require B2B partnerships. Best option: **Widgety Cruise API** (covers 60+ cruise lines, 1000+ ships, port schedules with times).

**Best practical approach for BVI Cruise Ship Schedule**: Continue scraping Crew Center and CruiseMapper (free, already working), supplement with VesselFinder port calls API for actual arrival/departure verification, and explore Widgety for forward-looking schedule data.

---

## 1. AIS / Maritime Vessel Tracking APIs

### 1a. MarineTraffic (now Kpler)
- **URL**: https://www.marinetraffic.com / https://servicedocs.marinetraffic.com/
- **Status**: Enterprise-only since January 2025 (removed credit system)
- **Relevant endpoints**:
  - `getExpected Port Arrivals` -- predicted arrivals at a port
  - `getPredictive Port Arrivals` -- ML-based arrival predictions
  - `getPort Calls` -- historical port call data
  - `getBerth Calls` -- berth-specific arrival/departure
  - `getSingle Vessel Port Calls` -- history for one vessel
  - `getVessel ETA to Port` -- ETA calculation
- **Data returned**: Arrival/departure times, vessel details, berth info
- **Pricing**: Enterprise contact only. No public pricing. Industry sources suggest $1,000+/month minimum. Removed the old credit-based system in Jan 2025.
- **Caribbean coverage**: Global AIS coverage (largest terrestrial + satellite network)
- **Verdict**: Too expensive for this use case. Designed for logistics companies tracking cargo.

### 1b. VesselFinder
- **URL**: https://www.vesselfinder.com/port-calls-api / https://api.vesselfinder.com/docs/
- **Relevant endpoint**: `/portcalls`
- **Query by port**: Yes -- use UN/LOCODE (e.g., `VGRTW` for Road Town)
- **Data returned**:
  - PortCall dataset (2 credits/record): port name, country, timestamp, event type (arrival/departure)
  - AIS dataset (+1 credit): position, speed, course, draught, destination, ETA
  - Voyage dataset (+1 credit): last port, departure timestamp
- **Pricing (credit-based, valid 12 months)**:
  - 10,000 credits: EUR 330 (~$360)
  - 20,000 credits: EUR 625 (~$680)
  - 50,000 credits: EUR 1,470 (~$1,600)
- **How it works**: Query `/portcalls?locode=VGRTW&interval=1440` to get all arrivals/departures at Road Town in the last 24 hours. Each record costs 2 credits. If ~300 cruise calls/year at Tortola, that's ~600 credits/year for arrival/departure records.
- **Limitations**: Returns AIS-derived data (actual positions), not scheduled times. No passenger capacity. No future schedule data -- only what AIS shows.
- **Caribbean coverage**: Global terrestrial + satellite AIS
- **Verdict**: BEST VALUE for verifying actual arrival/departure times. At ~600 credits/year for Tortola port calls, the EUR 330 package would last 15+ years. Could also track Virgin Gorda and Jost Van Dyke.

### 1c. FleetMon
- **URL**: https://www.fleetmon.com / https://developer.fleetmon.com/
- **Status**: DISCONTINUED -- migrated into MarineTraffic/Kpler. Login no longer possible.
- **Verdict**: Dead. Do not pursue.

### 1d. Spire Global
- **URL**: https://spire.com / https://maritime.spire.com/
- **Data**: Largest proprietary satellite AIS constellation. 600K+ vessels detected daily. Data back to 2010. ML-powered port ETAs and route predictions.
- **Pricing**: Enterprise only. Industry sources indicate >$10K/month.
- **Verdict**: Way too expensive. Designed for hedge funds and commodity traders.

### 1e. Datalastic
- **URL**: https://datalastic.com/
- **Data**: Historical and real-time AIS, port calls with ETA, vessel database
- **Pricing**: Starts at EUR 199/month. Credit-based with monthly reset.
- **Port calls endpoint**: Available but details behind paywall
- **Verdict**: More expensive than VesselFinder for equivalent data. Monthly subscription model less favorable for low-volume use.

### 1f. Data Docked
- **URL**: https://datadocked.com/
- **Data**: Satellite + terrestrial AIS, 2-year historical archive, PSC inspection records
- **Pricing**: From EUR 80/month, credit-based. Free trial with 10 credits.
- **Verdict**: Newer entrant. Could be worth testing with free trial, but limited documentation on port call endpoints.

### 1g. MyShipTracking
- **URL**: https://api.myshiptracking.com/
- **Endpoints**: Port Calls, Vessels In Port, Port Estimate (ETA predictions), Port Search
- **Pricing**: Credit-based. Trial: 2,000 coins for 10 days.
- **Limitations**: Terrestrial AIS only (no satellite). Coverage gaps offshore. Caribbean coastal coverage may be limited.
- **Verdict**: Cheap trial to test, but terrestrial-only AIS is a concern for Caribbean island ports where receivers may be sparse.

### 1h. NavAPI
- **URL**: https://navapi.com/
- **Data**: AIS positions, vessel tracking, "Find Ships by Destination and ETA" endpoint
- **Pricing**: Sea Routing starts at EUR 6,900/year. AIS pricing per-token or per-fleet.
- **Verdict**: Expensive. Designed for shipping logistics, not cruise tracking.

### 1i. AISHub (FREE)
- **URL**: https://www.aishub.net/
- **Data**: Free AIS data exchange. Real-time positions in JSON/XML/CSV.
- **Requirement**: You must contribute AIS data from your own receiver to get access.
- **Limitations**: No port call endpoints. Raw AIS positions only -- you'd need to build your own port call detection logic. Coverage depends on community receivers.
- **Verdict**: Free but requires an AIS receiver (hardware). Not practical unless you're running an AIS station in the BVI.

### 1j. aisstream.io (FREE)
- **URL**: https://aisstream.io/
- **Data**: Free global AIS streaming via WebSockets. Track positions, port calls, vessel identity.
- **How it works**: Connect to `wss://stream.aisstream.io/v0/stream`, subscribe to geographic bounding boxes. Filter by MMSI.
- **Pricing**: FREE with API key registration
- **Limitations**: Real-time streaming only (not historical). You'd need to run a persistent listener to capture port calls as they happen. No scheduled data.
- **Verdict**: BEST FREE OPTION for building your own real-time tracking. Set up a background job that listens for cruise ships entering a bounding box around Tortola/Virgin Gorda/JVD. Requires running infrastructure (a persistent WebSocket connection).

---

## 2. Cruise-Specific APIs (Booking/Content)

### 2a. Widgety Cruise API
- **URL**: https://widgety.org/product/cruise-api/
- **Data**: Itineraries from 60+ cruise lines, 1,000+ ships. Port visits with day numbers, timings (arrival/departure if provided by cruise line), lat/long, UNLOCODE. Ship details, images, brochures.
- **Pricing**: Not publicly listed. Contact for test API key. Likely B2B subscription.
- **Port schedule detail**: "Day number and timings are included if they're provided" -- meaning arrival/departure times come from cruise line data, which is exactly what schedule sites like Crew Center publish.
- **Search filters**: Can search by port of call, date range, cruise ship.
- **Verdict**: MOST PROMISING for automated schedule data. If pricing is reasonable, this could replace manual scraping entirely. Request a test API key to evaluate.

### 2b. CRUISEHOST / cruise-api.com
- **URL**: https://www.cruise-api.com/
- **Data**: All major cruise companies, real-time booking and pricing. 20+ years in cruise tech.
- **Focus**: Booking engine for travel agents (B2C/B2B). Books cabins, not just schedules.
- **Pricing**: Not public. Likely requires B2B agreement.
- **Verdict**: Overkill. This is a full booking API, not a schedule data feed.

### 2c. Traveltek Cruise API
- **URL**: https://www.traveltek.com/travel-api-provider/cruise-api/
- **Data**: 27+ cruise suppliers, 30,000+ itineraries, ship descriptions, cabin info.
- **Focus**: Travel agency booking platform.
- **Verdict**: Same as CRUISEHOST -- booking-focused, not schedule-focused.

### 2d. TravelScrape (Scraping Service)
- **URL**: https://www.travelscrape.com/cruise-voyage-data-scraping-api.php
- **Data**: Scraped cruise schedules, pricing, cabin availability from multiple cruise websites.
- **Pricing**: Custom quotes. Contact sales.
- **Verdict**: This is a scraping-as-a-service company. You're paying them to scrape the same sites you could scrape yourself. Not useful.

---

## 3. Scraping / Free Data Sources

### 3a. CruiseMapper via Apify
- **URL**: https://apify.com/vulnv/cruisemapper-cruises-scraper
- **Data**: Ship names, itineraries, departure dates, prices. Structured JSON/CSV/Excel.
- **Pricing**: Free tier limited to 5 results/run. Paid Apify plans for unlimited.
- **Verdict**: Useful as a backup automation, but Apify free tier is very limited.

### 3b. CruiseMapper via GitHub scraper (Python)
- **URL**: https://github.com/AmmarByFar/cruisemapper-scraper
- **Data**: Itinerary ID, cruise line, ship name, date, time, port, max passengers, crew
- **Tech**: Python + requests + BeautifulSoup
- **Pricing**: FREE (open source)
- **Verdict**: IMMEDIATELY USEFUL. This scraper already extracts exactly the data fields we need from CruiseMapper. Could adapt for Tortola-specific scraping. Handles pagination, dedup, rate limiting.

### 3c. Crew Center (manual/custom scraping)
- **URL**: https://crew-center.com/road-town-tortola-bvi-cruise-ship-schedule
- **Data**: Date, ship name, cruise line, arrival/departure times, passenger capacity
- **Status**: Already scraping this (see historical-data-research.md). Simple HTML tables.
- **Verdict**: CURRENT PRIMARY SOURCE. Keep scraping weekly.

### 3d. CruiseTimetables.com
- **URL**: https://www.cruisetimetables.com/
- **Data**: Ship schedules by port, day, month, year. All major cruise lines.
- **API**: None. Would require custom scraping.
- **Verdict**: Good backup source but no API.

### 3e. CruiseDig
- **URL**: https://cruisedig.com/ports/tortola-british-virgin-islands
- **Data**: Port calendar with scheduled arrivals.
- **API**: None. Forward-looking only.
- **Verdict**: Backup scraping source.

---

## 4. Port Authority Systems

### 4a. PortCall.com (BVI)
- **URL**: https://bvi.portcall.com/
- **What it is**: Cloud-based port scheduling platform for ports, pilots, and agents.
- **API**: None publicly documented. The BVI instance exists but no data feed.
- **Verdict**: Internal port operations tool. Not accessible for external data consumers.

### 4b. BVIPA (BVI Ports Authority)
- **URL**: https://bviports.org/
- **Data**: Press releases with annual/quarterly passenger counts. No ship-level schedule data published online.
- **API**: None.
- **Verdict**: Good for aggregate statistics. Not useful for daily schedules.

### 4c. VIPA (VI Port Authority, USVI)
- **URL**: https://www.viport.com/schedule-cruise-ports
- **Data**: Cruise ship schedules published as downloadable documents (PDF). Covers St. Thomas and St. Croix.
- **API**: None.
- **Verdict**: Manual download only. Could scrape the schedule page periodically.

### 4d. UN/EDIFACT / Port Community Systems
- **Status**: EDIFACT is the standard for electronic port data exchange, but these are internal B2B systems between shipping lines, port authorities, and agents. Not publicly accessible. Modern implementations use REST/JSON but are still private B2B.
- **Verdict**: Not accessible to external consumers.

---

## 5. Comparison Matrix

| Source | Data Type | Arrival/Departure Times | Passenger Capacity | Caribbean/BVI | Cost | Automation |
|--------|-----------|------------------------|-------------------|---------------|------|------------|
| **VesselFinder API** | AIS port calls | Actual (AIS-derived) | No | Global | EUR 330/yr min | REST API |
| **aisstream.io** | AIS streaming | Real-time only | No | Global | Free | WebSocket |
| **Widgety Cruise API** | Cruise line schedules | Scheduled (if provided) | Via ship data | Global | Unknown (B2B) | REST API |
| **CruiseMapper scraper** | Cruise schedules | Scheduled | Yes | Global | Free (OSS) | Python script |
| **Crew Center scraping** | Cruise schedules | Scheduled | Yes | BVI-specific | Free (DIY) | Custom scraper |
| **MarineTraffic** | AIS + port calls | Both actual and predicted | No | Global | $1000+/mo | REST API |
| **Datalastic** | AIS + port calls | Actual + ETA | No | Global | EUR 199+/mo | REST API |
| **MyShipTracking** | AIS port calls | Actual (terrestrial only) | No | Limited | Credit-based | REST API |
| **Data Docked** | AIS + PSC data | Actual | No | Global | EUR 80+/mo | REST API |
| **CRUISEHOST API** | Booking data | Scheduled | Via ship data | Global | B2B contract | REST API |

---

## 6. Recommended Strategy

### Immediate (Free, already working)
1. **Keep scraping Crew Center** weekly for Tortola/VG/JVD schedules. This is the most complete BVI-specific source with ship names, times, and passenger capacity.
2. **Add CruiseMapper scraping** using the open-source Python scraper (https://github.com/AmmarByFar/cruisemapper-scraper). Cross-reference with Crew Center data.

### Short-term (Low cost, high value)
3. **VesselFinder Port Calls API** (EUR 330 for 10K credits). Use to verify actual arrival/departure times vs scheduled times. Query `/portcalls?locode=VGRTW` daily. At ~2 credits per record and ~300 cruise calls/year, this budget lasts many years. Also track `VGSPT` (Virgin Gorda) and JVD.
4. **Request Widgety test API key**. If their cruise API has good BVI port schedule data with times, this could be the cleanest automated source.

### Medium-term (If budget allows)
5. **aisstream.io WebSocket listener**. Build a Stimulus/background job that monitors a bounding box around BVI for cruise ship AIS signals. Free but requires persistent infrastructure. Could provide real-time "ship is approaching" alerts.

### Not worth pursuing
- MarineTraffic/Kpler -- too expensive for this use case
- Spire Global -- way too expensive ($10K+/mo)
- FleetMon -- discontinued
- CRUISEHOST/Traveltek -- booking APIs, wrong use case
- Port authority APIs -- none exist publicly
- NavAPI -- too expensive
- TravelScrape -- just paying someone to scrape for you

---

## 7. Key UN/LOCODEs for BVI

| Port | LOCODE | Notes |
|------|--------|-------|
| Road Town, Tortola | VGRTW | Main cruise pier |
| Spanish Town, Virgin Gorda | VGSPT | Anchorage calls |
| Jost Van Dyke | VGJVD | Anchorage calls (may not have LOCODE in all systems) |

---

## 8. Next Steps

1. [ ] Request Widgety test API key (https://widgety.org/product/cruise-api/)
2. [ ] Test VesselFinder API with EUR 330 credit package -- query `VGRTW` port calls
3. [ ] Clone and test the CruiseMapper Python scraper for Tortola-specific data
4. [ ] Register for free aisstream.io API key and test WebSocket connection with BVI bounding box
5. [ ] Continue weekly Crew Center scraping (current primary source)
