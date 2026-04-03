namespace :usvi do
  desc "Seed USVI ports, locations, thresholds, and config"
  task seed: :environment do
    puts "Seeding USVI ports..."
    charlotte_amalie = Port.find_or_create_by!(slug: "charlotte-amalie") do |p|
      p.name = "Charlotte Amalie, St. Thomas"
      p.latitude = 18.3358
      p.longitude = -64.9307
      p.territory = "usvi"
    end
    charlotte_amalie.update!(territory: "usvi")

    frederiksted = Port.find_or_create_by!(slug: "frederiksted") do |p|
      p.name = "Frederiksted, St. Croix"
      p.latitude = 17.7128
      p.longitude = -64.8826
      p.territory = "usvi"
    end
    frederiksted.update!(territory: "usvi")

    puts "Seeding USVI locations..."
    usvi_locations = [
      { name: "Magens Bay", slug: "magens-bay", port: charlotte_amalie },
      { name: "Sapphire and Coki Beaches", slug: "coki-beach", port: charlotte_amalie },
      { name: "National Park Beaches, St. John", slug: "national-park-beaches", port: charlotte_amalie },
      { name: "Rainbow Beach", slug: "rainbow-beach", port: frederiksted },
      { name: "Buck Island", slug: "buck-island", port: frederiksted }
    ]

    usvi_locations.each do |attrs|
      loc = Location.find_or_create_by!(slug: attrs[:slug]) do |l|
        l.name = attrs[:name]
        l.territory = "usvi"
        l.port = attrs[:port]
      end
      loc.update!(territory: "usvi", port: attrs[:port])
    end

    puts "Seeding USVI crowd thresholds..."
    {
      "magens-bay" => { green_max: 100, yellow_max: 200 },
      "coki-beach" => { green_max: 100, yellow_max: 200 },
      "national-park-beaches" => { green_max: 100, yellow_max: 300 },
      "rainbow-beach" => { green_max: 100, yellow_max: 300 },
      "buck-island" => { green_max: 80, yellow_max: 250 }
    }.each do |slug, thresholds|
      loc = Location.find_by!(slug: slug)
      t = CrowdThreshold.find_or_initialize_by(location: loc)
      t.update!(thresholds)
    end

    puts "Seeding USVI app config..."
    {
      "charlotte_amalie_magens_bay_pct" => { value: "0.10", description: "% of Charlotte Amalie passengers at Magens Bay concurrently (peak hour)" },
      "charlotte_amalie_coki_beach_pct" => { value: "0.10", description: "% of Charlotte Amalie passengers at Coki Beach concurrently (peak hour)" },
      "charlotte_amalie_national_park_pct" => { value: "0.15", description: "% of Charlotte Amalie passengers taking St. John excursion" },
      "frederiksted_rainbow_beach_pct" => { value: "0.40", description: "% of Frederiksted passengers walking to Rainbow Beach" },
      "frederiksted_buck_island_pct" => { value: "0.15", description: "% of Frederiksted passengers taking Buck Island excursion" },
      "transit_time_magens_bay" => { value: "30", description: "Minutes from Charlotte Amalie to Magens Bay by taxi" },
      "transit_time_coki_beach" => { value: "30", description: "Minutes from Charlotte Amalie to Coki Beach by taxi" },
      "transit_time_national_park_beaches" => { value: "90", description: "Minutes from Charlotte Amalie to St. John beaches via ferry" },
      "transit_time_rainbow_beach" => { value: "5", description: "Minutes from Frederiksted pier to Rainbow Beach" },
      "transit_time_buck_island" => { value: "60", description: "Minutes from Frederiksted to Buck Island by excursion boat" }
    }.each do |key, attrs|
      AppConfig.find_or_create_by!(key: key) do |c|
        c.value = attrs[:value]
        c.description = attrs[:description]
      end
    end

    # Backfill BVI location port_ids
    puts "Backfilling BVI location port associations..."
    {
      "the-baths" => "spanish-town",
      "white-bay" => "jost-van-dyke",
      "cane-garden-bay" => "road-town"
    }.each do |loc_slug, port_slug|
      loc = Location.find_by(slug: loc_slug)
      port = Port.find_by(slug: port_slug)
      next unless loc && port
      loc.update!(port: port) if loc.port_id.nil?
    end

    puts "USVI seed complete!"
    puts "  Ports: #{Port.usvi.count}"
    puts "  Locations: #{Location.usvi.count}"
  end

  desc "Fix crowd model: thresholds, percentages, ramp config, recalculate all"
  task fix_crowd_model: :environment do
    puts "Updating White Bay thresholds (50/150 — tiny beach, any JVD ship = slammed)..."
    wb = Location.find_by!(slug: "white-bay")
    wb.crowd_threshold.update!(green_max: 50, yellow_max: 150)

    puts "Updating Magens Bay thresholds (100/200 — >2000 pax = red)..."
    magens = Location.find_by!(slug: "magens-bay")
    magens.crowd_threshold.update!(green_max: 100, yellow_max: 200)

    puts "Updating Coki Beach thresholds to match Magens Bay (100/200)..."
    coki = Location.find_by!(slug: "coki-beach")
    coki.crowd_threshold.update!(green_max: 100, yellow_max: 200)

    puts "Updating National Park Beaches thresholds (100/300)..."
    np = Location.find_by!(slug: "national-park-beaches")
    np.crowd_threshold.update!(green_max: 100, yellow_max: 300)

    puts "Updating contribution percentages..."
    AppConfig.set("charlotte_amalie_magens_bay_pct", "0.10")
    AppConfig.set("charlotte_amalie_coki_beach_pct", "0.10")
    AppConfig.set("road_town_white_bay_pct", "0.05")

    puts "Setting ramp durations (90 min up, 120 min down)..."
    AppConfig.set("ramp_up_minutes", "90")
    AppConfig.set("ramp_down_minutes", "120")

    puts "Recalculating all future crowd snapshots..."
    future_dates = CruiseVisit.where("visit_date >= ?", Date.current).distinct.pluck(:visit_date).sort
    CrowdCalculationService.calculate_for_dates(future_dates)

    puts "Done! Recalculated #{future_dates.size} dates."
  end
end
