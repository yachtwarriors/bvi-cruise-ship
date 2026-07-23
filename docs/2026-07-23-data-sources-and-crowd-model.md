# Data Sources & Crowd Model — Reference

**Date**: July 23, 2026
**Status**: Current. Supersedes the source recommendations in `cruise-schedule-api-research.md` (March 2026).

---

## 1. Sources

### PortCall — PRIMARY for BVI (authoritative)

```
GET https://bvi.portcall.com/PortCallServer/portcall/app/home/cruise/1
```

The BVI Ports Authority's own berth scheduling system, not an aggregator's copy of
it. Public, unauthenticated, no rate limiting, no anti-bot. One request returns the
entire schedule — roughly 1,230 calls out to January 2028, of which ~1,155 map to
ports we model.

| Field | Notes |
|---|---|
| `VesselName` | ALL CAPS. See §3 on name normalisation. |
| `Arrival` / `Deparature` | ISO 8601 with explicit `-04:00`. Note their misspelling of departure. |
| `BerthName` | Berth-level: `JVD-White Bay` is distinct from `JVD-Great Harbor`. |
| `ExpectedPassengerCount` | Passengers actually expected, **not** maximum capacity. |
| `Length` | Unused. |

The public site's `#!?tab=2&date=...&port=...` parameters are **client-side filters
only**. Every request returns a byte-identical payload — there is nothing to
paginate and no way to request a date range.

**Limitations**
- No past dates at all. Historical record must accumulate in our own database.
- No USVI equivalent (`usvi.`, `vipa.`, `stthomas.`, `stcroix.portcall.com` all fail).
- Undocumented endpoint. It can change without notice.
- Some overnight anchorages record a departure that precedes the arrival. Validate.
- Berth spellings vary (`JVD-Great Harbor` and `JVD-Great Harbour` are the same place).

### CruiseDig — PRIMARY for USVI, secondary for BVI

Arrivals and departures live on **separate pages** with identical markup:

```
https://cruisedig.com/ports/<port>/arrivals
https://cruisedig.com/ports/<port>/departures
```

Departures were never scraped before July 2026. The old code comment claiming
CruiseDig has no departure times was true only of the arrivals page. ~87% of calls
pair to a real departure; the rest carry a `23:59` "time unknown" sentinel.

Reports **maximum capacity**, so it needs the utilisation discount (see §2).

### Crew Center — DEAD, do not revive

Failed silently from **2026-04-03** for 111 days. Two stacked failures:

1. A Sucuri WAF returning HTTP 307. This is solvable in pure Ruby — the challenge is
   deterministic string concatenation, no JS engine required — and a working solver
   was demonstrated.
2. Behind the WAF, their own backend renders `An error occurred while fetching data
   from the API` for everyone. Their page now directs visitors to cruisedig.com.

Solving the WAF gets you a 200 and no data. Not worth further effort.

### CruiseMapper — manual cross-check only

Has arrivals, departures and **past dates**, which nothing else does. But only a
~1-month window, no passenger counts, and requires scraping. Useful for validating
a specific historical day. `robots.txt` permits it (only `/admin/` is disallowed).

### VIPA — USVI validator, not a feed

`viport.com/schedule-cruise-ports` publishes fiscal-year PDFs. No API. Suitable as
a periodic correctness check against CruiseDig, not as a live source.

### Source precedence

`ScraperOrchestratorService::SOURCE_RANK` — `portcall` (3) > `crew_center` (2) >
`cruisedig` (1). A weaker source never overwrites a stronger one on the same call.

---

## 2. Passenger counts

PortCall reports **expected** passengers. Every other source reports **maximum
capacity**, which overstates a real sailing.

The `capacity_utilization_pct` factor (0.85) exists to convert a maximum into a
realistic load. Applying it to an already-realistic figure double-counts the
discount. `CrowdCalculationService#passengers_aboard`:

- `expected_passengers` present → use it directly, no discount.
- Otherwise → `passenger_capacity * capacity_utilization_pct`.

Example: Norwegian Luna is 4,224 max capacity, 3,300 expected. We previously
modelled 3,590.

---

## 3. Gotchas that cost real time

**Ship name normalisation.** PortCall shouts every name. `"MSC OPERA".titleize`
produces `"Msc Opera"` — a different string from the `"MSC Opera"` other sources
use. Visits key on `(ship_name, visit_date, port_id)`, so a mismatch silently
creates a **second row for the same call and double-counts its passengers**.
`PortCallScraperService#canonical_ship_name` reuses the spelling already on file
and only applies formatting rules to genuinely new vessels. Always check for
case-variant duplicates after adding a source.

**Timestamps are stored UTC** in a `timestamp without time zone` column. Always
convert to `America/Virgin` before reading or displaying. Reading the raw column
and reporting it as local time is a 4-hour error.

**Berth mapping is deliberately incomplete.** `TORT-West End`, `TORT-Sopers Hole`
and `TORT-Beef Island` are skipped and logged, not guessed at. They are nowhere
near the Road Town cruise pier and folding them in would inflate Cane Garden Bay.

**`db/seeds.rb` runs on every deploy** (`release: rake db:migrate db:seed`). Any
threshold or config value hardcoded there will overwrite production on the next
push.

---

## 4. Crowd model

For each ship contributing to a location:

```
crowd_start  = max(arrival + transit, earliest_excursion_hour)
crowd_end    = departure - (transit + BASE_RETURN_BUFFER_MINUTES)
```

A trapezoid ramps up from `crowd_start`, plateaus, and ramps down to `crowd_end`.
Presence is **averaged across each hour at 5-minute resolution**.

### Defects fixed on 2026-07-23

All four were invisible while every ship carried a hardcoded 18:00 departure. Real
departure times exposed them.

1. **Overnight departures.** Measured from clock time, a 02:00 next-day sailing read
   as 120 minutes, making `crowd_end` negative. The ship was then dropped by
   `return 0 if crowd_end <= crowd_start` — silently, with no log. Now measured from
   the visit date.
2. **Inverted trapezoid.** Ramps of 90 + 120 minutes could exceed a short port
   stay, so `ramp_up_end` fell after `ramp_down_start` and the crowd never reached
   its true peak. Ramps are now capped at a third of the window.
3. **Return buffer.** `transit + 60` emptied beaches hours before the ship sailed.
   Excursions are scheduled against the sailing time. Now `transit + 30`.
4. **Midpoint sampling.** The trapezoid was evaluated at a single instant — the
   hour's midpoint — discarding any window that opened or closed mid-hour. Magens
   Bay on 2026-08-12 showed **0 people (green) at 13:00, between 431 and 112**,
   because Icon Of The Seas' crowd ran until 13:30 and the sample landed exactly on
   `crowd_end`.

> **A false green is the worst failure this tool can produce.** An overstated red
> costs someone a beach day. A false green sends them into the jam and destroys
> trust. When in doubt, err toward warning.

### Transit times

Sourced from Matt (local charter broker), July 2026. Seeded via
`rake crowd:seed_transit_times`. Anchorage figures are measured from when the ship
drops anchor and **include the tender ashore**.

| Route | Was | Now |
|---|---|---|
| Spanish Town → Baths | 90 | 30 |
| Road Town → Baths | 90 | 60 |
| Gorda Sound → Baths | 120 | 60 |
| Road Town → White Bay | *never set* | 45 |

`transit_time_white_bay_from_road_town` had **no `AppConfig` row at all** and was
silently falling through to a 90-minute code default. It never appeared in
`/manage`, so it could not have been tuned. When auditing config, check for missing
rows, not just wrong values. Code defaults are now aligned with the seeded values.

### pct and threshold are mathematically redundant

Only their **ratio** affects output. Raising `road_town_white_bay_pct` from 0.05 to
0.075 is exactly equivalent to lowering White Bay's `yellow_max` from 150 to 100.
The model cannot distinguish them. Estimate each independently from reality —
how many excursion boats actually run, and how many people make the beach feel
full — rather than curve-fitting one to make a day look right.

---

## 5. Crowd levels

Four bands: **green / yellow / orange / red**, labelled Low / Moderate / Busy /
High. `crowd_thresholds` holds `green_max`, `yellow_max`, `orange_max`.

Orange was added by splitting the **old yellow band**, leaving the red line exactly
where it was. Nothing that warned before stopped warning. Splitting the red band
instead would have quietly downgraded real warnings.

Effect on the ambiguous hours: 47–64% of yellow hours moved to orange, strongest on
**single-ship days (64%)** where yellow is the entire decision space. On three-ship
days almost everything is red already.

```
2026-07-22, The Baths
  before  YEL RED YEL YEL YEL YEL YEL YEL
  after   ORG RED ORG YEL ORG ORG ORG YEL
```

### Adding or changing a level — checklist

1. `CrowdSnapshot::INTENSITIES` — validated on save; a new value raises and kills
   the nightly scraper.
2. `PagesHelper` — colour, text, background, border, label, `INTENSITY_PRIORITY`.
3. **Grep every view for `case ... when "red" ... when "yellow" ... else`.** A new
   level falls through to `else` and renders as *Low Risk* — the exact
   under-warning failure the model work eliminated.
4. Mailer templates, both `.html.erb` and `.text.erb`.
5. `db/seeds.rb` and `lib/tasks/usvi_seed.rake`.
6. Rebuild Tailwind, or new colour classes render as blank cells.

### Thresholds are not to be tuned for colour balance

66% of crowded hours are red, and red lines sit 2.5–5x below each location's p90.

**Decision (Matt, 2026-07-23): red means red.** Orange exists to add granularity
*between* yellow and red, never to reduce red. If BVI crowding genuinely is bad
most days, the site should say so. Do not recalibrate thresholds to make a colour
appear more often.

The one legitimate open case is **Rainbow Beach**, where the yellow band catches 8
hours against orange's 71 — that band distinguishes nothing and could be re-split
without touching red.

---

## 6. Validation

**2026-07-22 is the reference day.** Independent ground truth from a BVI local:
White Bay "impossible to find a chair… wave after wave", Cane Garden Bay "more
jammed than I have ever seen it, ever".

Final model output: Cane Garden Bay red 09:00–16:00, White Bay red 10:00–16:00.

Check any future model change against this date. Note there is **no ground truth
for The Baths** on that day — it sits at 573 against a 600 red line, and neither
the 20% excursion share nor the threshold has been validated.

Useful automated check: flag any green hour with non-green hours on **both** sides.
This catches handoff artifacts, though it also legitimately fires on real lulls
between ships — a green hour holding 54 people between 431 and 112 is correct.

---

## 7. Operational

**There is no alerting.** No Slack, no email — Matt's decision. This is precisely
why Crew Center's failure went unnoticed for 111 days. Scraper health has no
surface today; the `/manage` dashboard is the only reasonable candidate.

Because nothing will page anyone, safety has to live in the code:

- **Pruning** removes future sailings that vanish from a source, but only when that
  source returned at least 50% of what is already on file **for that port**. A
  per-source guard was insufficient — CruiseDig covers seven ports in one pass, so
  one port returning an empty page could have deleted all 925 Charlotte Amalie
  sailings while the source-wide ratio still looked healthy.
- Past visits are never pruned. They are the historical record.
- Dates whose last ship was pruned are added to the recalculation set, or their
  stale snapshots would never be revisited.
