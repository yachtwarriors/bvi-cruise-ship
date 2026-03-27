# Matt Weidert — Full Context Document

*Drop this into any AI conversation, plugin, or agent prompt for full context.*
*Last updated: 2026-03-27*

---

## Who I Am

**Matt Weidert** — entrepreneur, Marine Corps veteran, real estate investor, sailor. Based in Castle Pines, Colorado. Married to Britney, two kids: Holden (3rd grade) and Collins (1st grade) at Buffalo Ridge Elementary. Family is in Douglas County School District. Holden plays Raptors 9U baseball (I'm Coach Matt).

I run multiple businesses and build all my own web properties. I'm a hands-on technical founder — I write code, do SEO, run ads, and make product decisions. I don't have a dev team; it's me + AI tools.

---

## My Companies

### Longleaf Lending (longleaflending.com)
- **What:** Veteran-owned hard money lending firm, founded 2020, headquartered in Texas
- **Co-founder:** Pete Underwood (also a veteran, Navy)
- **Business model:** Two sides — (1) balance sheet hard money lender (fix & flip, bridge, ground-up construction) and (2) DSCR/rental loan broker (originate & sell to secondary market)
- **Scale:** 600+ loans funded, $125M+ volume
- **Growth focus:** DSCR side is the high-growth play (unlimited capital since we broker, not hold)
- **Tech stack:** Ruby on Rails, Tailwind CSS, PostgreSQL, Heroku. HubSpot CRM, Mortgage Automator, Baseline for loan processing
- **SEO strategy:** City-specific keyword pages for DSCR loans, hard money loans, and rental markets across Texas (65+ cities). Blog with 49+ posts
- **Team:** Pete Underwood (Managing Partner), Matt Weidert (Managing Partner), John Harvey (Loan Officer), Fer Valicenti (Business Development)

### Yacht Warriors (yachtwarriors.com)
- **What:** Crewed yacht charter booking platform, veteran-owned
- **My expertise:** 15+ years sailing Caribbean and Bahamas, personally know captains, crews, anchorages, beach bars
- **Market:** BVI, Exumas, Caribbean crewed yacht charters
- **Scale:** 1,000+ URLs, 112 blog posts, deep destination content trees
- **Tech stack:** Rails 7.2, Ruby 3.3.5, PostgreSQL, Redis, Tailwind CSS, Hotwire (Turbo/Stimulus), Devise, Stripe, Postmark, Heroku, Cloudflare
- **Brand voice:** I write as the experienced friend, not a salesperson. First-person, conversational, specific, opinionated. "Salty. Generous. Opinionated. Genuine. Experienced."
- **Current initiatives:** SEO content expansion, Spanish translation, backlink building, Meta ads, newsletter growth
- **Has curated BVI POI database** (60+ locations) — useful for other charter-related projects

### CharterProtect (charterprotect.com)
- **What:** Yacht charter travel insurance distribution platform
- **Strategy:** Go direct to underwriters via InsurTech API partners (Battleface is top pick), not aggregator affiliate model
- **Revenue model:** 25-40% of premium as distribution partner ($625-1,200 per sale on a $25K charter)
- **Key selling point:** Cancel For Any Reason (CFAR) coverage — huge for charters with large non-refundable deposits
- **Competitive landscape:** Almost nobody in this niche. No dedicated US yacht charter insurance comparison site exists
- **Tech stack:** Rails 8, PostgreSQL, Tailwind CSS, Heroku
- **Status:** Site built, needs deployment and partner outreach

### Map Tracks
- **What:** Self-serve web app for creating beautiful nautical-style maps of sailing routes — print-quality keepsakes
- **Monetization:** Free to create (watermarked), pay to download high-res. Future: crew subscriptions, print fulfillment
- **Tech:** Rails 8, Stimulus, MapLibre GL JS, Tailwind CSS, Turf.js bezier splines, Puppeteer for 300 DPI PDF generation, GPX import
- **Market:** No direct competitor. BVI-focused marketing, works globally. Connected to Yacht Warriors audience
- **Status:** Editor prototype built, iterating on map style and route UX

### Colorado Pine Beetle (coloradopinebeetle.com)
- **What:** Lead gen site for pine bark beetle awareness/prevention/treatment on Colorado Front Range
- **Monetization:** Sell leads to tree care companies
- **Scale:** 25 city pages published, 1 blog post, 30+ prospect tree companies identified
- **Tech stack:** Rails 8, PostgreSQL, Tailwind CSS, Heroku
- **Status:** V1 live, needs content expansion and lead capture implementation

### History by Bill (historybybill.com)
- **What:** Blog for Bill's weekly American history emails
- **Tech stack:** Rails 8, PostgreSQL, Tailwind CSS, Action Text, Active Storage, Devise, Heroku
- **Status:** Core app built, testing end-to-end flows

### Housekeeper
- **What:** Rails app that runs scheduled AI agent tasks (my personal automation platform)
- **First task:** Family events scanner — scans Gmail for kids/family events, manages Google Calendars, posts summaries to Slack
- **Architecture:** Claude API as orchestrator with tool use. Prompts stored as markdown. 18 scanner tools. Prompt self-improvement system (learns from Slack feedback)
- **Tech:** Rails 8, PostgreSQL, Anthropic Ruby gem, Claude Haiku 4.5, Google APIs (Gmail + Calendar), Slack API
- **Deployed:** Heroku, scanner runs 3x/day

### Matt Weidert Personal Site (mattweidert.com)
- **What:** Personal portfolio/blog
- **Tech:** Rails 8, Tailwind CSS (Spotlight template ported from Next.js), PostgreSQL, Heroku
- **Status:** Scaffolded, pages rendering, needs content and deployment

---

## Tech Stack & Preferences

### Core Stack
- **Language:** Ruby (strongly preferred)
- **Framework:** Ruby on Rails (8.x for new projects, 7.x for Yacht Warriors)
- **Database:** PostgreSQL (runs on port 5433 locally, user: postgres, password: postgres)
- **CSS:** Tailwind CSS v4
- **Frontend:** Hotwire (Turbo + Stimulus) — no React, no heavy JS frameworks
- **Rich text:** Action Text (Trix editor)
- **File uploads:** Active Storage
- **Auth:** Devise (always disable public registration)
- **Hosting:** Heroku for everything
- **CDN/proxy:** Cloudflare
- **Email:** Postmark (transactional), ConvertKit (newsletters)
- **Environment:** Ruby 3.3.5, WSL2 on Windows, bash shell

### Blog Pattern (Reused Across Projects)
I have a standard blog implementation I use across all sites:
- Post model with Action Text body, Active Storage cover images, Tags (many-to-many via PostTag)
- Slug-based URLs at root level (catch-all route, must be last in routes.rb)
- SEO: meta tags, Open Graph, Twitter Cards, JSON-LD, Google Discover (max-image-preview:large), RSS feed, XML sitemap
- Admin-only editing behind Devise, no public registration
- Two-column post form: content left, sidebar right (draft toggle, date picker, tag checkboxes)

### AI / LLM Usage
- Claude Code as my primary development tool
- Anthropic API for Housekeeper (Claude Haiku 4.5 for cost efficiency)
- I build AI-powered features directly into my Rails apps
- Compound Engineering plugin for planning and review workflows

---

## How I Work (Preferences for AI Assistants)

### Communication Style
- Be direct and opinionated. Lead with the best move, don't present bad options equally
- Do the math — if something isn't worth pursuing, say so
- Be proactive with strategic recommendations
- No trailing summaries of what you just did (I can read the diff)
- Short, concise responses

### Workflow
- For any web project: prioritize getting live ASAP (domain aging, indexing) over perfecting content
- Save detailed research to `docs/` files in the project repo, organized by topic
- Never deploy or push to production without my review — let me see things locally first
- Don't create external resources (Heroku apps, databases, etc.) without asking
- Always visually test design/CSS changes before presenting them

### Git
- Never add "Co-Authored-By" lines to commit messages

### SEO Approach
- I do keyword research with Ahrefs
- City-specific programmatic SEO pages are a pattern I reuse (Longleaf DSCR pages, Pine Beetle city pages)
- I prioritize low-competition keywords where I can actually rank
- Content strategy: own the niche first, then expand to adjacent higher-volume terms

### Business Philosophy
- Ship fast, iterate based on data
- One-person operation + AI — I don't have a team, so everything needs to be maintainable by me
- Multiple niche sites > one big site
- Lead gen and affiliate models alongside direct businesses
- Veteran-owned branding is genuine, not performative

---

## Project Paths (Local)

| Project | Path |
|---------|------|
| Yacht Warriors | `/home/dreamstream/projects/yacht_warriors` |
| Longleaf Lending | `/home/dreamstream/projects/longleaf_lending` |
| Map Tracks | `/home/dreamstream/projects/map_tracks` |
| Pine Beetle | `/home/dreamstream/projects/pine-beetle` |
| CharterProtect | `/home/dreamstream/projects/claude/travel-insurance` |
| History by Bill | `/home/dreamstream/projects/claude/history_by_bill` |
| Housekeeper | `/home/dreamstream/projects/claude/housekeeper` |
| Matt Weidert | `/home/dreamstream/projects/matt_weidert` |
| BVI Cruise Ship | `/home/dreamstream/projects/bvi_cruise_ship` |

---

## Family Context (for Housekeeper / Calendar)
- School: Buffalo Ridge Elementary (BRE), Castle Pines, CO
- District: Douglas County School District (DCSD)
- Sports: Holden plays Raptors 9U baseball
- Club: Country Club at Castle Pines (CCA)
- Timezone: America/Denver
