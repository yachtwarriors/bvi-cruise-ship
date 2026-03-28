# Historical BVI Cruise Ship Data Research

**Date**: March 27, 2026

## Executive Summary

**Ship-by-ship historical records**: Available from Crew Center going back to 2017. This is the best source for daily historical schedules with ship names, cruise lines, and arrival/departure times. Passenger capacity is on the current page but not confirmed on all historical year pages.

**Monthly/annual aggregate statistics**: The BVI government publishes monthly cruise passenger counts in press releases and the Central Statistics Office has CSV downloads for at least 2019. Combined with press release data, we can reconstruct monthly figures for 2021-2024.

---

## 1. CruiseMapper - Historical Data

**Result: NO historical data. Forward-looking only.**

- URL: https://www.cruisemapper.com/ports/tortola-island-bvi-port-35
- Tested with `?tab=schedule&month=2025-01` parameter -- page ignores the past date and shows March 2026 forward
- Month selector only shows future months (March 2026 through April 2028)
- No way to access past schedules through the UI or URL parameters

---

## 2. Wayback Machine (web.archive.org)

**Result: Could not access directly (blocked by tool), but Crew Center has its own historical archive (see #7 below), making Wayback less important.**

- web.archive.org returned errors when fetched directly
- Google searches for `site:web.archive.org crew-center.com` returned no indexed results
- Wayback Machine snapshots likely exist but would need manual browser access to check
- **Less important now**: Crew Center maintains its own year-by-year archive pages (2017-2025)

---

## 3. BVI Government / Official Statistics

**Result: YES -- monthly aggregate data available through press releases and CSO downloads.**

### BVI Central Statistics Office (CSO)
- URL: https://bvi.gov.vg/statistics
- **Tourist Arrivals by Category 2019**: Available in both PDF and CSV format
- Additional years (2010-2016) also available as PDF/CSV downloads
- Data categorized "by type of visitor" (includes cruise vs. air arrivals)
- **Gap**: Only 2019 and 2010-2016 explicitly listed as downloadable. No 2020-2024 CSVs found online (may need to email CSO directly)
- Contact: Central Administration Complex, Road Town, Tortola (Mon-Fri 8:30am-4:30pm)

### Government Press Releases (Monthly Data Extracted)

The BVI government has published detailed monthly cruise passenger counts in several press releases:

**Monthly Data - 2021 (July-December)**:
| Month | Cruise Passengers |
|-------|------------------|
| July 2021 | 650 |
| August 2021 | 299 |
| September 2021 | 516 |
| October 2021 | 1,026 |
| November 2021 | 22,388 |
| December 2021 | 47,384 |
| **2021 Total (Jul-Dec)** | **72,263** |

**Monthly Data - 2022 (Full Year)**:
| Month | Cruise Passengers |
|-------|------------------|
| January 2022 | 36,602 |
| February 2022 | 32,002 |
| March 2022 | 44,951 |
| April 2022 | 26,446 |
| May 2022 | 16,382 |
| June 2022 | 19,119 |
| July 2022 | 9,894 |
| August 2022 | 14,825 |
| September 2022 | 5,959 |
| October 2022 | 13,546 |
| November 2022 | 45,997 |
| December 2022 | 7,852 |
| **2022 Total** | **265,723** |

**Monthly Data - 2023 (Jan-Aug)**:
| Month | Cruise Passengers |
|-------|------------------|
| January 2023 | 96,613 |
| February 2023 | 94,854 |
| March 2023 | 107,688 |
| April 2023 | 47,645 |
| May 2023 | 28,156 |
| June 2023 | 44,778 |
| July 2023 | 32,943 |
| August 2023 | 39,804 |
| **2023 Total (Jan-Aug)** | **492,481** |

Source: https://bvi.gov.vg/media-centre/statement-honourable-rymer-unprecedented-growth-cruise-passenger-arrivals-summer-2021

### Annual Totals (Compiled from Multiple Sources)

| Year | Cruise Passengers | Cruise Calls | Source |
|------|------------------|-------------|--------|
| Pre-2016 | ~370,000/yr avg | -- | BVI gov estimate |
| 2016 | 699,105 | -- | Previous record, cited in multiple releases |
| 2017 | ~700,000 (est) | -- | Near 2016 record before Irma (Sep 2017) |
| 2018-2019 | Reduced (Irma recovery) | -- | -- |
| 2020 | Near zero | -- | COVID shutdown |
| 2021 (Jul-Dec) | 72,263 | -- | Gov press release |
| 2022 | 265,723 (possibly 343,541-343,571*) | 263 | Gov press release / BVIPA |
| 2023 | 720,392 | 354 (232 pier + 122 anchorage) | BVIPA official |
| 2024 | 768,293 | -- | Gov press release |

*Note: Two different 2022 figures appear in government sources -- 265,723 (from the monthly breakdown) and 343,541/343,571 (from the BVIPA year-end release). The higher number likely includes crew or uses a different methodology.

### 2023 Cruise Calls by Location
| Location | Calls |
|----------|-------|
| Cruise Pier (Road Harbour) | 232 |
| Jost Van Dyke (anchorage) | 56 |
| Virgin Gorda (anchorage) | 38 |
| Road Harbour (anchorage) | 9 |
| Other locations | 19 |
| **Total** | **354** |

Source: https://bviports.org/bvipanews/unprecedented-success-record-breaking-cruise-arrivals

### Quarterly Highlights
- **Q1 2024**: 393,605 passengers (vs 299,605 in Q1 2023, +31.4%)
- **H1 2024**: ~490,000 cruise passengers (vs ~422,000 in H1 2023)

---

## 4. CruiseTimetables - Historical Data

**Result: NO. Past seasons are removed. Forward-looking only.**

- Tested multiple past URLs:
  - `/tortola-british-virgin-islands-cruise-ship-schedule-2025.html` -- redirects to 2026+ data
  - `/tortolabritishvirginislandsschedule-dec2025.html` -- shows 2026+ data only
  - `/tortolabritishvirginislandsschedule-15jan2025.html` -- shows 2026+ data only
- Historical season data appears to be purged once the season passes
- Only current and future schedules maintained

---

## 5. FCCA and Caribbean Tourism Organization

### FCCA (Florida-Caribbean Cruise Association)
- URL: https://www.f-cca.com/research.html
- Reports available from 2004-2024 as PDF downloads
- **2024 Caribbean Cruise Analysis** (Volumes I and II) -- most recent
- BVI-specific finding: $85.7M total cruise tourism spending in 2023-2024 period
- Reports cover 33 Caribbean/Latin American destinations with passenger surveys
- **No free BVI-specific passenger count data** -- aggregate regional stats only
- Per-destination data requires contacting research@f-cca.com
- FCCA renewed strategic development agreement with BVI in March 2025

### Caribbean Tourism Organization (OneCaribbean.org)
- URL: https://www.onecaribbean.org/statistics/
- Publishes annual "State of the Industry" reviews
- Has a BVI Visitor Arrival Summary document (PDF) but it appears to be older data (2010-era)
- Annual reviews and prospects available on their statistics page
- Monthly Caribbean-wide performance data published

### Tourism Analytics (tourismanalytics.com)
- URL: https://tourismanalytics.com/bvi-statistics.html
- Third-party aggregator of Caribbean tourism stats
- Shows BVI tourism performance statistics updated for 2025
- **403 error when fetched** -- may require subscription or have access restrictions

### Statista
- URL: https://www.statista.com/statistics/816368/british-virgin-islands-number-of-tourist-arrivals/
- Has BVI tourist arrival data but likely behind paywall

---

## 6. BVI Government Published Cruise Data

**Result: YES -- via press releases and limited CSO downloads. No dedicated cruise data portal.**

See Section 3 above for full details. Summary:
- Monthly data available: Jul 2021 through Aug 2023 (from one comprehensive press release)
- Annual totals: 2016, 2021-2024
- Quarterly data: Q1 2024, H1 2024
- Per-port cruise call breakdown: 2023 only
- CSO CSV downloads: 2019 and 2010-2016 (tourist arrivals by category)

---

## 7. Crew Center Historical Archive (KEY FINDING)

**Result: YES -- ship-by-ship daily historical data from 2017 to present.**

Crew Center maintains separate pages for each year's schedule:

| Year | URL | Status |
|------|-----|--------|
| 2017 | crew-center.com/tortola-cruise-ship-schedule-2017 | Confirmed: ~95-100 entries, full year |
| 2018 | crew-center.com/tortola-cruise-ship-schedule-2018 | Confirmed: 150+ entries, Dec 2017 - Jan 2019 |
| 2019 | crew-center.com/tortola-bvi-cruise-ship-schedule-2019 | Confirmed: Full year, multiple lines |
| 2020 | crew-center.com/road-town-tortola-bvi-cruise-ship-schedule-2020 | Confirmed: Oct 2020+, COVID caveat |
| 2021 | crew-center.com/british-virgin-islands-cruise-ports-schedules-2021 | Confirmed: Multi-port page |
| 2026 | crew-center.com/road-town-tortola-bvi-cruise-ship-schedule | Current (forward-looking) |

### Data Fields by Year Page:
- **2017**: Date, ship name, cruise line, arrival/departure times (~95 entries)
- **2018**: Date, ship name, cruise line, arrival/departure times (150+ entries)
- **2019**: Date, ship name, cruise line, arrival/departure times (full year)
- **2020**: Date, ship name, cruise line, arrival/departure times, guest count, crew count
- **2026 (current)**: Date, ship name, cruise line, passenger capacity, arrival/departure times

### Port Coverage:
- Road Town, Tortola (primary)
- Virgin Gorda / Spanish Town
- Jost Van Dyke
- Norman Island

### URL Pattern (not fully consistent):
- 2017: `/tortola-cruise-ship-schedule-2017`
- 2018: `/tortola-cruise-ship-schedule-2018`
- 2019: `/tortola-bvi-cruise-ship-schedule-2019`
- 2020: `/road-town-tortola-bvi-cruise-ship-schedule-2020`
- 2021: `/british-virgin-islands-cruise-ports-schedules-2021`

URLs are not perfectly predictable -- would need to discover 2022-2025 URLs (if they exist).

---

## 8. CruiseDig - Historical Data

**Result: NO. Forward-looking only.**

- Tested `?date=2025-01-15` parameter -- ignored, shows March 2026+ data
- No archive or past-date navigation found

---

## Summary: What We Can Get

### Daily Ship-by-Ship Records
| Source | Years Available | Data Quality |
|--------|----------------|-------------|
| Crew Center archive | 2017-2020 confirmed, possibly 2021-2025 | Ship name, line, date, arrival/departure times. Pax on some years. |
| Wayback Machine | Unknown (needs manual check) | Would capture whatever was on Crew Center/CruiseTimetables at snapshot time |

### Monthly/Annual Aggregate Data
| Source | Years Available | Data Quality |
|--------|----------------|-------------|
| BVI Gov press releases | Monthly: Jul 2021 - Aug 2023. Annual: 2016, 2021-2024 | Passenger counts only (no ship detail) |
| BVI CSO CSV downloads | 2010-2016, 2019 | Tourist arrivals by category (cruise vs. air) |
| BVIPA news | 2022-2023 | Annual totals + per-port cruise call counts |
| FCCA reports | 2004-2024 | Regional aggregates, BVI spending data |

### Recommended Action Plan

1. **Scrape Crew Center historical pages** (2017-2020+) -- this gives us the ship-by-ship daily records needed for "today vs. average" and "this month vs. last year" comparisons. Simple HTML tables, easy to parse.

2. **Download BVI CSO CSV files** (2019, 2010-2016) from bvi.gov.vg/statistics -- these give monthly cruise passenger totals by category.

3. **Extract monthly data from government press releases** -- the Honourable Rymer statement has month-by-month data from Jul 2021 through Aug 2023. Hardcode this into a seed data migration.

4. **Email BVI Central Statistics Office** -- request 2020-2024 monthly cruise arrival data in CSV format. They clearly track it but haven't published all years online.

5. **Check Wayback Machine manually** (in a browser) for Crew Center snapshots from 2022-2025 to fill any gaps in the year-archive pages.

6. **Start accumulating our own data now** -- scrape current schedules weekly and store them. In 12 months we'll have a full year of our own verified data.
