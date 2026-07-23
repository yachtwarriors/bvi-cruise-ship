namespace :crowd do
  # Transit values sourced from Matt (local BVI charter broker) on 2026-07-23.
  # Anchorage figures are measured from the moment the ship drops anchor and
  # include the tender shuttle ashore, not just the road leg.
  TRANSIT_TIMES = {
    "transit_time_baths_from_virgin_gorda" => {
      value: "30",
      description: "Minutes from Spanish Town anchorage to The Baths — tender ashore + safari truck"
    },
    "transit_time_baths_from_road_town" => {
      value: "60",
      description: "Minutes from Road Town to The Baths via excursion ferry + transport"
    },
    "transit_time_baths_from_gorda_sound" => {
      value: "60",
      description: "Minutes from Gorda Sound anchorage to The Baths — tender ashore + taxi"
    },
    "transit_time_white_bay_from_road_town" => {
      value: "45",
      description: "Minutes from Road Town to White Bay, JVD by excursion boat / water taxi"
    },
    # Raised from 0.05 on 2026-07-23. At 5% a single ship peaked at 143 against a
    # 150 red line, so White Bay could never go red on a one-ship afternoon —
    # contradicted by on-the-ground reports from 2026-07-22.
    "road_town_white_bay_pct" => {
      value: "0.075",
      description: "% of Road Town passengers at White Bay concurrently (peak hour)"
    }
  }.freeze

  desc "Seed/update transit times used by the crowd model"
  task seed_transit_times: :environment do
    TRANSIT_TIMES.each do |key, attrs|
      config = AppConfig.find_or_initialize_by(key: key)
      before = config.persisted? ? config.value : "(unset)"
      config.assign_attributes(value: attrs[:value], description: attrs[:description])
      config.save!
      puts "#{key}: #{before} -> #{attrs[:value]}"
    end
  end
end
