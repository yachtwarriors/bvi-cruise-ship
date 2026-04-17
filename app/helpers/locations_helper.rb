module LocationsHelper
  LOCATION_CONFIGS = {
    "the-baths" => {
      route_name: :the_baths,
      title: "The Baths BVI Crowd Forecast — Best Time to Visit Today",
      description: "Check today's crowd forecast at The Baths, Virgin Gorda. See hourly crowd risk from cruise ship visitors, best time to visit, and the 7-day forecast.",
      keywords: "the baths bvi, best time to visit the baths, the baths virgin gorda crowded, the baths cruise ship crowds",
      og_title: "The Baths BVI — Crowd Forecast & Best Time to Visit",
      hero_image: "the-baths-3.jpg",
      hero_alt: "The Baths, Virgin Gorda BVI",
      port_route: :virgin_gorda,
      port_name: "Virgin Gorda",
      territory: "bvi",
      about: "The Baths National Park on Virgin Gorda is the BVI's most iconic attraction — massive granite boulders forming grottoes, tidal pools, and a stunning snorkeling trail. It's also the #1 excursion destination for cruise ship passengers, which means crowds can be intense on ship days."
    },
    "cane-garden-bay" => {
      route_name: :cane_garden_bay,
      title: "Cane Garden Bay Crowd Forecast — Cruise Ship Crowd Tracker",
      description: "Check today's crowd forecast at Cane Garden Bay, Tortola. See hourly crowd risk from cruise ship visitors and the best time to visit.",
      keywords: "cane garden bay, cane garden bay tortola, cane garden bay crowded, cane garden bay cruise ships",
      og_title: "Cane Garden Bay — Crowd Forecast & Best Time to Visit",
      hero_image: "the-baths-4.jpg",
      hero_alt: "Cane Garden Bay, Tortola BVI",
      port_route: :tortola,
      port_name: "Tortola",
      territory: "bvi",
      about: "Cane Garden Bay is Tortola's most popular beach — a long crescent of white sand with beach bars, water sports, and calm swimming. It's a 20-minute taxi ride from the Road Town cruise terminal, making it a common destination on ship days."
    },
    "white-bay" => {
      route_name: :white_bay,
      title: "White Bay Crowd Forecast — Jost Van Dyke Cruise Ship Crowds",
      description: "Check today's crowd forecast at White Bay, Jost Van Dyke. See hourly crowd risk from cruise ship visitors and the best time to visit.",
      keywords: "white bay jost van dyke, white bay bvi, white bay crowded, jost van dyke cruise ships",
      og_title: "White Bay, Jost Van Dyke — Crowd Forecast & Best Time to Visit",
      hero_image: "white-bay-bvi-3.jpg",
      hero_alt: "White Bay, Jost Van Dyke BVI",
      port_route: :tortola,
      port_name: "Tortola",
      territory: "bvi",
      about: "White Bay on Jost Van Dyke is famous for the Soggy Dollar Bar and its pristine white sand beach. When cruise ships anchor at Jost Van Dyke, passengers are tendered ashore and White Bay can go from tranquil to packed."
    },
    "magens-bay" => {
      route_name: :magens_bay,
      title: "Magens Bay Crowd Forecast — St. Thomas Cruise Ship Crowds",
      description: "Check today's crowd forecast at Magens Bay, St. Thomas. See hourly crowd risk from cruise ship visitors and the best time to visit.",
      keywords: "magens bay, magens bay st thomas, magens bay crowded, magens bay cruise ships",
      og_title: "Magens Bay — Crowd Forecast & Best Time to Visit",
      hero_image: "magens-bay.jpg",
      hero_alt: "Magens Bay, St. Thomas USVI",
      port_route: :st_thomas,
      port_name: "St. Thomas",
      territory: "usvi",
      about: "Magens Bay is consistently rated one of the world's most beautiful beaches. It's a 20-minute taxi ride from the Charlotte Amalie cruise terminals, making it one of the top excursion destinations on ship days. Entrance fee is $5 per person."
    },
    "coki-beach" => {
      route_name: :coki_beach,
      title: "Sapphire and Coki Beaches Crowd Forecast — St. Thomas Cruise Ship Crowds",
      description: "Check today's crowd forecast at Sapphire and Coki Beaches, St. Thomas. See hourly crowd risk from cruise ship visitors and the best time to visit.",
      keywords: "coki beach st thomas, sapphire beach st thomas, coki beach crowded, coki beach cruise ships",
      og_title: "Sapphire & Coki Beaches — Crowd Forecast & Best Time to Visit",
      hero_image: "magens-bay.jpg",
      hero_alt: "Sapphire and Coki Beaches, St. Thomas USVI",
      port_route: :st_thomas,
      port_name: "St. Thomas",
      territory: "usvi",
      about: "Coki Beach and Sapphire Beach are on St. Thomas's east end, next to Coral World Ocean Park. They're popular cruise excursion stops — a 25-minute taxi ride from the Havensight terminal. Coki Beach is known for excellent snorkeling right from shore."
    },
    "national-park-beaches" => {
      route_name: :national_park_beaches,
      title: "National Park Beaches Crowd Forecast — St. John Cruise Ship Crowds",
      description: "Check today's crowd forecast at Trunk Bay, Cinnamon Bay, and other National Park Beaches on St. John. See hourly crowd risk from cruise ship visitors.",
      keywords: "trunk bay st john, national park beaches st john, trunk bay crowded, st john cruise ship crowds",
      og_title: "National Park Beaches, St. John — Crowd Forecast",
      hero_image: "magens-bay.jpg",
      hero_alt: "National Park Beaches, St. John USVI",
      port_route: :st_thomas,
      port_name: "St. Thomas",
      territory: "usvi",
      about: "Virgin Islands National Park covers two-thirds of St. John, with beaches like Trunk Bay, Cinnamon Bay, and Maho Bay. Cruise passengers reach St. John via excursion boats or the Red Hook ferry from St. Thomas — about 45 minutes from the cruise terminal."
    },
    "rainbow-beach" => {
      route_name: :rainbow_beach,
      title: "Rainbow Beach Crowd Forecast — St. Croix Cruise Ship Crowds",
      description: "Check today's crowd forecast at Rainbow Beach, St. Croix. See hourly crowd risk from cruise ship visitors and the best time to visit.",
      keywords: "rainbow beach st croix, rainbow beach frederiksted, rainbow beach crowded, st croix cruise ship crowds",
      og_title: "Rainbow Beach, St. Croix — Crowd Forecast & Best Time to Visit",
      hero_image: "magens-bay.jpg",
      hero_alt: "Rainbow Beach, St. Croix USVI",
      port_route: :st_croix,
      port_name: "St. Croix",
      territory: "usvi",
      about: "Rainbow Beach is steps from the Frederiksted cruise pier on St. Croix's west coast. It fills up fast on ship days because passengers can walk there in under 5 minutes. The beach has calm, clear water and good snorkeling along the pier."
    },
    "buck-island" => {
      route_name: :buck_island,
      title: "Buck Island Crowd Forecast — St. Croix Cruise Ship Crowds",
      description: "Check today's crowd forecast at Buck Island Reef National Monument, St. Croix. See hourly crowd risk from cruise ship excursion boats.",
      keywords: "buck island st croix, buck island reef, buck island crowded, buck island cruise ships",
      og_title: "Buck Island, St. Croix — Crowd Forecast",
      hero_image: "magens-bay.jpg",
      hero_alt: "Buck Island, St. Croix USVI",
      port_route: :st_croix,
      port_name: "St. Croix",
      territory: "usvi",
      about: "Buck Island Reef National Monument is a protected island off St. Croix's northeast coast with an underwater snorkeling trail. Cruise excursion boats typically depart from Frederiksted or Christiansted, arriving about an hour after the ship docks."
    }
  }.freeze

  def location_config_for(slug)
    LOCATION_CONFIGS[slug]
  end
end
