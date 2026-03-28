# Monetization Foundation Plan

**Date:** 2026-03-28
**Scope:** ~30 minutes of template work + coordination with email stream

## Approach

Contextual, helpful CTAs — not ads. Yacht Warriors CTA only appears on yellow/red crowd days (when the suggestion to "book a private charter" actually makes sense). CharterProtect is a soft footer link always visible.

## Step 1: Helper Methods (`app/helpers/pages_helper.rb`)

```ruby
def day_peak_intensity(date, locations, snapshots)
  locations.map { |loc|
    peak_intensity_for(snapshots[[date, loc.id]] || [])
  }.max_by { |i| { "red" => 3, "yellow" => 2, "green" => 1 }[i] || 0 }
end
```

## Step 2: Yacht Warriors CTA in Day Cards (`app/views/pages/home.html.erb`)

Inside the `@dates.each` loop, after the `@locations.each` block, before the card closes. Only renders on yellow/red days.

```erb
<% day_peak = day_peak_intensity(date, @locations, @snapshots) %>
<% if day_peak.in?(%w[yellow red]) %>
  <div class="mx-4 mb-4 rounded-lg border border-cyan-200 bg-cyan-50 px-4 py-3 flex items-center justify-between gap-3">
    <div>
      <% if day_peak == "red" %>
        <p class="text-sm font-medium text-cyan-900">Big cruise day ahead</p>
        <p class="text-xs text-cyan-700">Skip the crowds entirely with a private yacht charter.</p>
      <% else %>
        <p class="text-sm font-medium text-cyan-900">Planning around the crowds?</p>
        <p class="text-xs text-cyan-700">A private charter gives you the flexibility to explore on your schedule.</p>
      <% end %>
    </div>
    <a href="https://yachtwarriors.com?utm_source=bvicruise&utm_medium=web&utm_campaign=crowd_cta&utm_content=<%= day_peak %>"
       target="_blank" rel="noopener"
       class="shrink-0 rounded-md bg-cyan-600 px-3 py-2 text-xs font-semibold text-white hover:bg-cyan-500 transition">
      Yacht Warriors →
    </a>
  </div>
<% end %>
```

## Step 3: CharterProtect Footer (`app/views/pages/home.html.erb`)

After the existing "Built with 🩵 by Yacht Warriors" footer:

```erb
<div class="mt-2 text-center text-xs text-slate-400">
  Booking a charter?
  <a href="https://charterprotect.com?utm_source=bvicruise&utm_medium=web&utm_campaign=footer_cp"
     target="_blank" rel="noopener" class="text-cyan-600 hover:text-cyan-500 font-medium">
    Protect your trip with CharterProtect →
  </a>
</div>
```

## Step 4: Email Cross-Sell (R13)

Coordinate with Stream 2 email template:

**YW CTA in email** — conditional, only on yellow/red days:
- After crowd summary section
- Copy: "Skip the crowds with a private yacht charter. [Book with Yacht Warriors →]"
- URL: `https://yachtwarriors.com?utm_source=bvicruise&utm_medium=email&utm_campaign=daily_alert&utm_content=yw`

**CharterProtect in email** — always present, in footer:
- Copy: "Booking a charter? Protect your trip with CharterProtect."
- URL: `https://charterprotect.com?utm_source=bvicruise&utm_medium=email&utm_campaign=daily_alert&utm_content=cp`

## UTM Parameter Reference

| Link | utm_source | utm_medium | utm_campaign | utm_content |
|------|-----------|-----------|-------------|-------------|
| YW CTA (web) | bvicruise | web | crowd_cta | yellow/red |
| YW CTA (email) | bvicruise | email | daily_alert | yw |
| CP footer (web) | bvicruise | web | footer_cp | — |
| CP footer (email) | bvicruise | email | daily_alert | cp |

## File Summary

| File | Change |
|------|--------|
| `app/helpers/pages_helper.rb` | Add `day_peak_intensity` helper |
| `app/views/pages/home.html.erb` | Add YW CTA block + CP footer line |
| Daily alert email template (TBD) | Add YW CTA + CP footer when email is built |
