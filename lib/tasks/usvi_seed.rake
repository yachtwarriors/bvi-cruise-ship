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
      { name: "Coki Beach", slug: "coki-beach", port: charlotte_amalie },
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
      "magens-bay" => { green_max: 300, yellow_max: 800 },
      "coki-beach" => { green_max: 150, yellow_max: 400 },
      "national-park-beaches" => { green_max: 200, yellow_max: 600 },
      "rainbow-beach" => { green_max: 100, yellow_max: 300 },
      "buck-island" => { green_max: 80, yellow_max: 250 }
    }.each do |slug, thresholds|
      loc = Location.find_by!(slug: slug)
      t = CrowdThreshold.find_or_initialize_by(location: loc)
      t.update!(thresholds)
    end

    puts "Seeding USVI app config..."
    {
      "charlotte_amalie_magens_bay_pct" => { value: "0.25", description: "% of Charlotte Amalie passengers visiting Magens Bay" },
      "charlotte_amalie_coki_beach_pct" => { value: "0.20", description: "% of Charlotte Amalie passengers visiting Coki Beach" },
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
end
