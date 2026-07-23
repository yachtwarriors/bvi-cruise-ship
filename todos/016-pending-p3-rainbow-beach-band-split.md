---
status: pending
priority: p3
issue_id: "016"
tags: [crowd-model, thresholds]
dependencies: []
---

# Rainbow Beach yellow band distinguishes nothing

## Problem Statement
Rainbow Beach's yellow band catches 8 hours against orange's 71 over the next
year. Values jump effectively straight from green to orange, so the four-level
scale buys no extra resolution at that location.

Current bands: green <= 100, yellow <= 200, orange <= 300, red > 300.

## Findings
Distribution of in-band hours (2026-07-22 through +365d):

| Location | yellow | orange |
|---|---|---|
| Rainbow Beach | **8** | **71** |
| The Baths | 201 | 319 |
| White Bay | 222 | 168 |
| Cane Garden Bay | 146 | 101 |
| National Park | 171 | 159 |
| Magens Bay | 134 | 97 |
| Sapphire and Coki | 134 | 97 |
| Buck Island | 72 | 85 |

Every other location splits its in-between hours reasonably. Rainbow Beach is the
lone outlier.

## Next Steps
Raise the yellow/orange boundary for Rainbow Beach so both sub-bands carry signal.
Update `lib/tasks/usvi_seed.rake` as well as the database, since `db:seed` runs on
every deploy.

## Constraints
**Do not move the red line.** Per Matt 2026-07-23: "red means red, don't turn red
into orange for the sake of trying to include orange." This change must only
re-split the existing yellow/orange range.

Note also that Rainbow Beach's absolute thresholds were seeded as guesses during
the USVI expansion and have never been validated against anything on the ground.
