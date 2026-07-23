---
status: pending
priority: p2
issue_id: "015"
tags: [seo]
dependencies: []
---

# Homepage SERP snippet is body copy, not a meta description

## Problem Statement
Google's result for bvicruiseshipschedule.com renders scraped body copy ending in
"Then we ...Read more" instead of a controlled meta description. No branded title
line is showing either.

Observed 2026-07-23:

> We pull published cruise ship schedules daily — ship names, passenger capacity,
> arrival and departure times, and which BVI port they're visiting. Then we ...Read more

## Findings
- Snippet appears to be lifted from homepage body content rather than a `<meta name="description">`.
- "Read more" implies the crawled text is inside a truncated/expandable block.
- The copy promises **departure times**, which the site did not actually have from
  2026-04-03 (Crew Center outage) until the CruiseDig `/departures` fix. Claim is
  becoming true again with that change — verify it has shipped before optimizing copy.

## Next Steps
- Audit homepage meta description (Metamagic config) vs. what's crawled.
- Check whether the "Read more" wrapper hides content from crawlers.
- Rewrite description around the actual differentiator: per-ship arrival AND departure
  times plus hourly crowd forecast per beach.

## Notes
Deferred by Matt on 2026-07-23 — "address this later".
