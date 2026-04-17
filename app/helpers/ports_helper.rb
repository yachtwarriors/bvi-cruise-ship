module PortsHelper
  PORT_CONFIGS = {
    "road-town" => {
      page_slug: "tortola",
      route_name: :tortola,
      title: "Tortola Cruise Ship Schedule — Road Town Port Crowd Tracker",
      description: "Check today's Tortola cruise ship schedule. See which ships are at Road Town, passenger counts, and hourly crowd risk at The Baths, Cane Garden Bay, and White Bay.",
      keywords: "tortola cruise ship schedule, tortola cruise port, road town cruise ship schedule, cruise ships in tortola today, tortola port schedule, tortola cruise schedule",
      og_title: "Tortola Cruise Ship Schedule & Crowd Tracker",
      og_description: "Track cruise ships at Road Town, Tortola. See hourly crowd risk at The Baths, Cane Garden Bay, and White Bay.",
      hero_image: "the-baths-3.jpg",
      hero_alt: "The Baths, Virgin Gorda BVI",
      h1: "Tortola Cruise Ship Schedule",
      hero_text: "Track cruise ships at <strong class=\"text-white\">Road Town</strong>. See hourly crowd risk at <strong class=\"text-white\">The Baths</strong>, <strong class=\"text-white\">Cane Garden Bay</strong>, and <strong class=\"text-white\">White Bay</strong> — so you can plan around the crowds.".html_safe,
      territory: "bvi",
      schedule_url: "https://bvicruiseshipschedule.com/tortola",
      logistics: [
        "Cruise ships dock at Road Town Harbour on Tortola's south coast.",
        "Taxis and tour operators meet ships at the pier. Negotiate fares before riding.",
        "Cane Garden Bay is a 20-minute taxi ride over the hill from the cruise terminal.",
        "The Baths (Virgin Gorda) is accessible via 30-minute ferry excursion from Road Town.",
        "White Bay (Jost Van Dyke) is reachable by water taxi — typically a separate excursion."
      ],
      how_it_works: "We pull published cruise ship schedules daily and estimate hourly crowd levels at The Baths, Cane Garden Bay, and White Bay based on which ships are at Road Town, their passenger capacity, and arrival/departure times. The Baths gets crowds from Road Town ships selling ferry excursions to Virgin Gorda. Cane Garden Bay fills up because it's a short taxi ride from the pier. White Bay sees traffic when Jost Van Dyke water taxis run from Road Town."
    },
    "virgin-gorda" => {
      page_slug: "virgin-gorda",
      route_name: :virgin_gorda,
      title: "Virgin Gorda Cruise Ship Schedule — Spanish Town Port & The Baths Crowd Tracker",
      description: "Check today's Virgin Gorda cruise ship schedule. See which ships are at Spanish Town and Gorda Sound, passenger counts, and hourly crowd risk at The Baths.",
      keywords: "virgin gorda cruise ship schedule, spanish town cruise ship schedule, the baths bvi crowded, virgin gorda cruise port",
      og_title: "Virgin Gorda Cruise Ship Schedule & Crowd Tracker",
      og_description: "Track cruise ships at Virgin Gorda. See hourly crowd risk at The Baths based on ship schedules and passenger counts.",
      hero_image: "north-sound-4.jpg",
      hero_alt: "North Sound, Virgin Gorda BVI",
      h1: "Virgin Gorda Cruise Ship Schedule",
      hero_text: "Track cruise ships at <strong class=\"text-white\">Spanish Town</strong> and <strong class=\"text-white\">Gorda Sound</strong>. See hourly crowd risk at <strong class=\"text-white\">The Baths</strong> — the BVI's most popular attraction.".html_safe,
      territory: "bvi",
      schedule_url: "https://bvicruiseshipschedule.com/virgin-gorda",
      logistics: [
        "Cruise ships tender passengers to the dock at Spanish Town (The Valley) on Virgin Gorda's south end.",
        "The Baths National Park is a short taxi ride south from Spanish Town — about 10 minutes.",
        "Some smaller ships anchor in Gorda Sound (North Sound) — passengers tender to shore and taxi to The Baths.",
        "The Baths has a $3 per person national park entrance fee. Arrive early to beat the crowds.",
        "Taxi fares are government-regulated. Expect ~$5-7 per person from the dock to The Baths."
      ],
      how_it_works: "We pull published cruise ship schedules daily and estimate hourly crowd levels at The Baths based on which ships are at Spanish Town and Gorda Sound, their passenger capacity, and arrival/departure times. The Baths is the primary excursion destination for virtually all cruise ship passengers visiting Virgin Gorda."
    },
    "charlotte-amalie" => {
      page_slug: "st-thomas",
      route_name: :st_thomas,
      title: "St. Thomas Cruise Ship Schedule — Charlotte Amalie Port Crowd Tracker",
      description: "Check today's St. Thomas cruise ship schedule. See which ships are at Charlotte Amalie, passenger counts, and hourly crowd risk at Magens Bay, Sapphire and Coki Beaches, and National Park Beaches.",
      keywords: "st thomas cruise ship schedule, charlotte amalie cruise ships, cruise ship schedule st thomas usvi, port of st thomas cruise ship schedule, st thomas cruise port",
      og_title: "St. Thomas Cruise Ship Schedule & Crowd Tracker",
      og_description: "Track cruise ships at Charlotte Amalie, St. Thomas. See hourly crowd risk at Magens Bay, Coki Beach, and National Park Beaches.",
      hero_image: "magens-bay.jpg",
      hero_alt: "Magens Bay, St. Thomas USVI",
      h1: "St. Thomas Cruise Ship Schedule",
      hero_text: "Track cruise ships at <strong class=\"text-white\">Charlotte Amalie</strong>. See hourly crowd risk at <strong class=\"text-white\">Magens Bay</strong>, <strong class=\"text-white\">Sapphire and Coki Beaches</strong>, and <strong class=\"text-white\">National Park Beaches</strong>.".html_safe,
      territory: "usvi",
      schedule_url: "https://bvicruiseshipschedule.com/st-thomas",
      logistics: [
        "Cruise ships dock at Havensight or Crown Bay terminals in Charlotte Amalie, St. Thomas.",
        "Magens Bay is a 20-minute taxi ride from both terminals. Beach entrance fee is $5 per person.",
        "Coki Beach and Coral World are a 25-minute taxi ride east from Havensight.",
        "National Park Beaches (Trunk Bay, Cinnamon Bay) on St. John are accessible via the Red Hook ferry — about 45 minutes from the cruise terminal.",
        "Open-air safari taxis run set routes. Negotiate fares for custom trips."
      ],
      how_it_works: "We pull published cruise ship schedules daily and estimate hourly crowd levels at popular beaches based on which ships are at Charlotte Amalie, their passenger capacity, and arrival/departure times. Magens Bay and Coki Beach fill up because they're short taxi rides from the cruise terminals. National Park Beaches on St. John get hit when passengers take excursion boats or the Red Hook ferry."
    },
    "frederiksted" => {
      page_slug: "st-croix",
      route_name: :st_croix,
      title: "St. Croix Cruise Ship Schedule — Frederiksted Port Crowd Tracker",
      description: "Check today's St. Croix cruise ship schedule. See which ships are at Frederiksted, passenger counts, and hourly crowd risk at Rainbow Beach and Buck Island.",
      keywords: "st croix cruise ship schedule, frederiksted cruise ships, cruise ship schedule st croix, rainbow beach st croix, buck island",
      og_title: "St. Croix Cruise Ship Schedule & Crowd Tracker",
      og_description: "Track cruise ships at Frederiksted, St. Croix. See hourly crowd risk at Rainbow Beach and Buck Island.",
      hero_image: "magens-bay.jpg",
      hero_alt: "Frederiksted, St. Croix USVI",
      h1: "St. Croix Cruise Ship Schedule",
      hero_text: "Track cruise ships at <strong class=\"text-white\">Frederiksted</strong>. See hourly crowd risk at <strong class=\"text-white\">Rainbow Beach</strong> and <strong class=\"text-white\">Buck Island</strong>.".html_safe,
      territory: "usvi",
      schedule_url: "https://bvicruiseshipschedule.com/st-croix",
      logistics: [
        "Cruise ships dock at the Ann E. Abramson Pier in Frederiksted on St. Croix's west coast.",
        "Rainbow Beach is steps from the cruise pier — walkable in under 5 minutes.",
        "Buck Island Reef National Monument is accessible by excursion boat from Frederiksted or Christiansted (~45 minutes).",
        "Christiansted (the other main town) is a 30-minute taxi ride east.",
        "Taxis and tour operators meet ships at the pier."
      ],
      how_it_works: "We pull published cruise ship schedules daily and estimate hourly crowd levels at Rainbow Beach and Buck Island based on which ships are at Frederiksted, their passenger capacity, and arrival/departure times. Rainbow Beach fills up fast because it's steps from the cruise pier. Buck Island gets excursion boat traffic typically arriving about an hour after the ship docks."
    }
  }.freeze

  def port_config_for(slug)
    key = slug == "virgin-gorda" ? "virgin-gorda" : slug
    PORT_CONFIGS[key]
  end
end
