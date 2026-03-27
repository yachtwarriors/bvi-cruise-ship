# Ports
puts "Seeding ports..."
[
  { name: "Road Town, Tortola", slug: "road-town", latitude: 18.4267, longitude: -64.6200 },
  { name: "Spanish Town, Virgin Gorda", slug: "spanish-town", latitude: 18.4468, longitude: -64.4270 },
  { name: "Jost Van Dyke", slug: "jost-van-dyke", latitude: 18.4433, longitude: -64.7533 },
  { name: "Norman Island", slug: "norman-island", latitude: 18.3200, longitude: -64.6200 }
].each do |attrs|
  Port.find_or_create_by!(slug: attrs[:slug]) do |p|
    p.name = attrs[:name]
    p.latitude = attrs[:latitude]
    p.longitude = attrs[:longitude]
  end
end

# Locations (crowd-tracked attractions)
puts "Seeding locations..."
[
  { name: "The Baths", slug: "the-baths" },
  { name: "White Bay", slug: "white-bay" }
].each do |attrs|
  Location.find_or_create_by!(slug: attrs[:slug]) do |l|
    l.name = attrs[:name]
  end
end

# Crowd thresholds (starting defaults — Matt will tune these after observing real data)
puts "Seeding crowd thresholds..."
baths = Location.find_by!(slug: "the-baths")
white_bay = Location.find_by!(slug: "white-bay")

baths_threshold = CrowdThreshold.find_or_initialize_by(location: baths)
baths_threshold.update!(green_max: 200, yellow_max: 600)

white_bay_threshold = CrowdThreshold.find_or_initialize_by(location: white_bay)
white_bay_threshold.update!(green_max: 100, yellow_max: 300)

# App config defaults
puts "Seeding app config..."
{
  "transit_time_baths_from_virgin_gorda" => { value: "90", description: "Minutes from Spanish Town dock to The Baths for cruise excursion groups" },
  "transit_time_baths_from_road_town" => { value: "120", description: "Minutes from Road Town to The Baths via ferry excursion" },
  "transit_time_white_bay_from_jost" => { value: "20", description: "Minutes from Jost Van Dyke landing to White Bay" },
  "road_town_baths_excursion_pct" => { value: "0.20", description: "Estimated % of Road Town cruise passengers who take The Baths excursion" },
  "capacity_utilization_pct" => { value: "0.85", description: "Estimated % of max ship capacity that's actually aboard" },
  "ramp_down_minutes" => { value: "90", description: "Minutes before departure when crowd starts thinning" }
}.each do |key, attrs|
  AppConfig.find_or_create_by!(key: key) do |c|
    c.value = attrs[:value]
    c.description = attrs[:description]
  end
end

# Admin user
puts "Seeding admin..."
Admin.find_or_create_by!(email: "matt@yachtwarriors.com") do |a|
  a.password = "password"
end

puts "Seed complete!"
