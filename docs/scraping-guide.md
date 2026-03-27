# BVI Cruise Ship Schedule Scraping Guide

**Date**: March 27, 2026
**Purpose**: Exact HTML structures for building a Ruby/Nokogiri scraper

---

## Source 1: Crew Center (RECOMMENDED PRIMARY SOURCE)

### Overview
- **Platform**: Drupal 10 CMS
- **Rendering**: 100% server-rendered HTML. No JavaScript data loading. Tables are inline in the page source.
- **Curl-friendly**: Yes. Standard HTTP GET with no auth, no cookies, no JS required.
- **Rate limiting**: None observed. Be polite (1-2 second delay between requests).

### URLs for All 4 BVI Ports

| Port | URL | CruiseDig Full Schedule Link |
|------|-----|-----|
| Road Town, Tortola | `https://crew-center.com/road-town-tortola-bvi-cruise-ship-schedule` | `https://cruisedig.com/node/163` |
| Virgin Gorda (Spanish Town) | `https://crew-center.com/virgin-gorda-spanish-town-bvi-cruise-ship-schedule` | `https://cruisedig.com/node/164` |
| Jost Van Dyke | `https://crew-center.com/jost-van-dyke-bvi-cruise-ship-schedule` | `https://cruisedig.com/node/161` |
| Norman Island | `https://crew-center.com/norman-island-bvi-cruise-ships-schedule` | `https://cruisedig.com/node/162` |

**NOTE**: The `www.` subdomain has an SSL cert mismatch (cert only covers `crew-center.com`, not `www.crew-center.com`). Always use `https://crew-center.com/...` without `www.`.

### HTML Table Structure (EXACT)

Each page has **two tables** side by side in a `div.grid.grid-cols-2.gap-4` container:
1. **Arrivals table** (left) -- header: "Ship" / "Arrive"
2. **Departures table** (right) -- header: "Ship" / "Departure"

Both tables use identical structure.

#### Exact HTML for one table:

```html
<div class="grid grid-cols-2 gap-4">
  <div>
    <table class="cruidedig-schedule border-0">
      <thead>
        <tr class="text-left">
          <th class="p-2">Ship</th>
          <th class="p-2">Arrive</th>
        </tr>
      </thead>
      <tbody>
        <tr class="even:bg-blue-50/80">
          <td class="ship p-2">
            Marella Discovery 2
            <small>Marella Cruises</small>
            <small>2.198 passengers</small>
          </td>
          <td class="p-2 text-sm">28 Mar 2026 - 08:00</td>
        </tr>
        <!-- more rows... -->
      </tbody>
    </table>
  </div>
  <div>
    <table class="cruidedig-schedule border-0">
      <thead>
        <tr class="text-left">
          <th class="p-2">Ship</th>
          <th class="p-2">Departure</th>
        </tr>
      </thead>
      <tbody>
        <!-- same row structure, departure times -->
      </tbody>
    </table>
  </div>
</div>
```

#### Key observations about the Ship cell (`td.ship`):

The `<td class="ship p-2">` contains THREE text nodes separated by `<small>` tags:
1. **Ship name**: Direct text node (e.g., `Marella Discovery 2`)
2. **Cruise line**: First `<small>` child (e.g., `Marella Cruises`)
3. **Passenger capacity**: Second `<small>` child (e.g., `2.198 passengers`)

**IMPORTANT**: Passenger capacity uses **European decimal notation** -- a period instead of a comma. `2.198 passengers` means 2,198 passengers. `5.074 passengers` means 5,074. Parse accordingly.

#### Date/time cell format:
`DD Mon YYYY - HH:MM` (e.g., `28 Mar 2026 - 08:00`)
- 24-hour time format
- Month is 3-letter English abbreviation
- Some entries show `23:59` which likely means "time not specified" or "overnight stay"

### Nokogiri Scraping Code (Ruby)

```ruby
require 'nokogiri'
require 'open-uri'

url = "https://crew-center.com/road-town-tortola-bvi-cruise-ship-schedule"
doc = Nokogiri::HTML(URI.open(url))

# Get both tables
tables = doc.css("table.cruidedig-schedule")
arrivals_table = tables[0]    # First table = arrivals
departures_table = tables[1]  # Second table = departures

# Parse arrivals
arrivals = {}
arrivals_table.css("tbody tr").each do |row|
  ship_td = row.css("td.ship")
  time_td = row.css("td:nth-child(2)")

  # Ship name is the first text node (before any <small> tags)
  ship_name = ship_td.children.first.text.strip

  # Cruise line and passengers are in <small> tags
  smalls = ship_td.css("small")
  cruise_line = smalls[0]&.text&.strip
  passengers_raw = smalls[1]&.text&.strip  # "2.198 passengers"

  # Parse passenger count (European decimal -> integer)
  passengers = passengers_raw&.gsub(/[^\d.]/, '')&.gsub('.', '')&.to_i

  # Parse date/time
  datetime_str = time_td.text.strip  # "28 Mar 2026 - 08:00"

  arrivals[ship_name] = {
    cruise_line: cruise_line,
    passengers: passengers,
    arrival_datetime: datetime_str
  }
end

# Parse departures and merge
departures_table.css("tbody tr").each do |row|
  ship_td = row.css("td.ship")
  time_td = row.css("td:nth-child(2)")

  ship_name = ship_td.children.first.text.strip
  datetime_str = time_td.text.strip

  if arrivals[ship_name]
    arrivals[ship_name][:departure_datetime] = datetime_str
  end
end
```

### Data Fields Available

| Field | Source | Example |
|-------|--------|---------|
| Ship name | `td.ship` first text node | `Norwegian Epic` |
| Cruise line | `td.ship small:nth-child(1)` | `Norwegian Cruise Line` |
| Passenger capacity | `td.ship small:nth-child(2)` | `5.074 passengers` |
| Arrival date+time | Arrivals table, 2nd `<td>` | `30 Mar 2026 - 08:00` |
| Departure date+time | Departures table, 2nd `<td>` | `30 Mar 2026 - 17:00` |

### Schedule Range & Limitations

- **Road Town, Tortola**: Shows ~10 days of upcoming arrivals (28 Mar - 06 Apr 2026 as of today). Limited window.
- **Virgin Gorda**: Shows 28 Mar 2026 - Dec 2026. Wider range for smaller ports.
- **Jost Van Dyke**: Shows 31 Mar 2026 - Dec 2026+.
- **Norman Island**: Shows 15 Nov 2026 - Jan 2027.

**CRITICAL LIMITATION**: Crew Center only shows a LIMITED upcoming window (~15 rows per table). For the full schedule, they link to CruiseDig.com. Road Town shows only ~10 days ahead; smaller ports show more because they have fewer visits.

### "Full Schedule" via CruiseDig

Each Crew Center page has a "Need more data?" CTA linking to CruiseDig:
```html
<a href="https://cruisedig.com/node/163" target="_blank" class="...">
  Full Port Schedule
</a>
```

CruiseDig node IDs:
- Tortola: `/node/163`
- Virgin Gorda: `/node/164`
- Jost Van Dyke: `/node/161`
- Norman Island: `/node/162`

CruiseDig shows ~20 entries per page with pagination (`?page=1`, `?page=2`, etc.). Full arrivals at:
`https://cruisedig.com/ports/tortola-british-virgin-islands/arrivals`

---

## Source 2: CruiseTimetables (SECONDARY SOURCE -- berth location data)

### Overview
- **Rendering**: Server-rendered HTML
- **Curl-friendly**: NO. Returns 403 Forbidden to curl/wget. Requires browser-like User-Agent header or possibly Selenium/Ferrum.
- **Structure**: Two-tier -- index pages list dates, detail pages show ship data

### URL Patterns

#### Index pages (date listings, no ship data):
| Port | URL |
|------|-----|
| Tortola | `https://www.cruisetimetables.com/tortola-british-virgin-islands-cruise-ship-schedule.html` |
| Virgin Gorda | `https://www.cruisetimetables.com/virgin-gorda-british-virgin-islands-cruise-ship-schedule.html` |

These pages only show clickable date numbers organized by month/year. No ship names inline.

#### "Visiting" index pages (alternative view):
| Port | URL |
|------|-----|
| Tortola | `https://www.cruisetimetables.com/cruises-to-tortola-british-virgin-islands.html` |
| Virgin Gorda | `https://www.cruisetimetables.com/cruises-to-virgin-gorda-british-virgin-islands.html` |
| Jost Van Dyke | `https://www.cruisetimetables.com/cruises-to-jost-van-dyke-british-virgin-islands.html` |

Same thing -- date links only, organized by year/month.

#### Detail pages (ACTUAL SHIP DATA):
URL pattern: `[prefix]-[DD][mon][YYYY].html`

| Port | URL Pattern | Example |
|------|-------------|---------|
| Tortola (schedule) | `tortolabritishvirginislandsschedule-DDmonYYYY.html` | `tortolabritishvirginislandsschedule-01apr2026.html` |
| Tortola (visiting) | `visitingtortolabritishvirginislands-DDmonYYYY.html` | `visitingtortolabritishvirginislands-28mar2026.html` |
| Virgin Gorda | `visitingvirgingordabritishvirginislands-DDmonYYYY.html` | `visitingvirgingordabritishvirginislands-28mar2026.html` |
| Jost Van Dyke | `visitingjostvandykebritishvirginislands-DDmonYYYY.html` | `visitingjostvandykebritishvirginislands-27mar2026.html` |

Note: Both `tortolabritishvirginislandsschedule-` and `visitingtortolabritishvirginislands-` prefixes exist for Tortola.

### Date Range
Covers 2026 through April 2028 (approximately 25 months ahead).

### Detail Page HTML Structure

The detail pages use a **table** structure:

```html
<table>
  <tr><!-- header row -->
    <td>Day</td>
    <td>Cruise Line</td>
    <td>Ship</td>
    <td>Times</td>
    <td>Passengers</td>
  </tr>
  <tr><!-- data row -->
    <td>Wed 1</td>
    <td><img alt="Disney Cruise Line" ...></td>
    <td><a href="/cruise-ship-disney-treasure.html">Disney Treasure</a></td>
    <td>a 0815 d 1400</td>
    <td>2500</td>
  </tr>
</table>
```

#### Time format in detail pages:
`a HHMM d HHMM` where `a` = arrival, `d` = departure (e.g., `a 0815 d 1400`)
Some entries omit times entirely.

#### Nokogiri selectors for detail pages:
```ruby
doc.css('table tr')[1..-1].each do |row|  # Skip header
  cells = row.css('td')
  day = cells[0].text.strip
  cruise_line = cells[1].css('img')&.first&.[]('alt')
  ship_name = cells[2].css('a').text.strip
  ship_url = cells[2].css('a')&.first&.[]('href')
  times = cells[3].text.strip  # "a 0815 d 1400"
  passengers = cells[4].text.strip.to_i
end
```

### Scraping Strategy for CruiseTimetables

Because it blocks curl, you need either:
1. **Custom User-Agent header**: Try `User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)...`
2. **Ferrum/Selenium**: Headless Chrome for JavaScript-resistant scraping
3. **Mechanize gem**: May work with proper headers

The index pages provide all the date URLs you need. Scrape the index first to get all valid dates, then scrape each detail page.

**Scraping volume**: ~500 detail pages for Tortola alone (2026-2028). Be very polite with delays.

### Unique Data: Berth Location

The main schedule page (`tortola-british-virgin-islands-cruise-ship-schedule.html`) is the ONLY source that explicitly labels whether ships dock at:
- **Road Town Cruise Pier** (main pier, big ships)
- **Soper's Hole tender pier** (West End, 5 miles away, smaller ships)

This data is NOT on the detail pages -- only on the main schedule page header/description. It may not be per-ship, just general guidance.

---

## Source 3: CruiseDig (FULL SCHEDULE EXTENSION OF CREW CENTER)

### Overview
- Crew Center's "full schedule" links point to CruiseDig
- Same data source (both run by same team), but CruiseDig has pagination and longer date range
- Uses `<li>` list items, not `<table>` elements

### URLs

| Port | Arrivals URL |
|------|-------------|
| Tortola | `https://cruisedig.com/ports/tortola-british-virgin-islands/arrivals` |
| Virgin Gorda | `https://cruisedig.com/ports/virgin-gorda-british-virgin-islands/arrivals` (assumed pattern) |
| Jost Van Dyke | `https://cruisedig.com/ports/jost-van-dyke-british-virgin-islands/arrivals` (assumed pattern) |

### Pagination
- 20 items per page
- URL: `?page=0` (first), `?page=1` (second), etc.
- "Next page" link available in pagination nav

### Data per entry
- Ship name (linked to ship page)
- Cruise line (linked)
- Passenger capacity
- Date + time

### Date range
Tortola shows at least March 28 - June 10, 2026 across paginated pages.

---

## Recommendation: Scraping Architecture

### Phase 1 (Quick Win): Crew Center Only
- Scrape 4 pages, one per BVI port
- Gets you arrival AND departure times, ship names, cruise lines, passenger capacity
- ~15 upcoming entries per port (limited window but enough to start)
- Simple Nokogiri parsing, no pagination needed

### Phase 2 (Full Coverage): CruiseDig Pagination
- Scrape arrivals + departures pages for each port with pagination
- Gets full schedule (months out)
- Merge arrival + departure data by ship name + date

### Phase 3 (Berth Data): CruiseTimetables
- Scrape detail pages for berth/pier location data
- Requires headless browser or proper User-Agent
- Highest scraping complexity

### Key Implementation Notes

1. **European decimal in passenger counts**: Crew Center uses `2.198` to mean `2,198`. Strip the period and parse as integer.
2. **23:59 times**: Likely means "time unknown" or "stays overnight." Flag these specially.
3. **Match arrivals to departures**: Join on ship name + date (same ship can visit same port on different dates).
4. **Respect robots.txt**: Check each site before scraping.
5. **Cache aggressively**: Schedules change rarely. Scrape weekly at most.
6. **SSL note**: `crew-center.com` has cert issues on `www.` subdomain. Use bare domain.
