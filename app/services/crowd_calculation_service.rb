class CrowdCalculationService
  BVI_TIMEZONE = "America/Virgin".freeze
  HOURS_RANGE = (7..17).freeze

  # Passengers need to be back on the ship well before departure.
  # They leave the attraction ~2 hours before ship departure.
  RETURN_TO_SHIP_BUFFER_MINUTES = 120

  # Earliest excursion tours start running
  EARLIEST_EXCURSION_HOURS = {
    # BVI
    Location::THE_BATHS => 8 * 60 + 30,
    Location::WHITE_BAY => 9 * 60,
    Location::CANE_GARDEN_BAY => 8 * 60 + 30,
    # USVI
    Location::MAGENS_BAY => 8 * 60 + 30,
    Location::COKI_BEACH => 8 * 60 + 30,
    Location::NATIONAL_PARK_BEACHES => 9 * 60,
    Location::RAINBOW_BEACH => 8 * 60,
    Location::BUCK_ISLAND => 9 * 60
  }.freeze

  def self.calculate_for_dates(dates)
    new.calculate_for_dates(dates)
  end

  def calculate_for_dates(dates)
    locations = Location.includes(:crowd_threshold).all

    dates.each do |date|
      visits = CruiseVisit.includes(:port).where(visit_date: date)
      locations.each do |location|
        calculate_for_location_date(location, date, visits)
      end
    end
  end

  private

  def calculate_for_location_date(location, date, visits)
    threshold = location.crowd_threshold
    return unless threshold

    contributing_visits = find_contributing_visits(location, visits)

    HOURS_RANGE.each do |hour|
      estimated = 0
      ships = []

      contributing_visits.each do |visit, contribution_pct|
        visitors = estimate_visitors_at_hour(visit, location, hour, contribution_pct)
        next unless visitors > 0

        estimated += visitors
        ships << { name: visit.ship_name, pax: visitors, port: visit.port.name }
      end

      # No "none" — if there's no cruise ship impact, it's green (low risk)
      intensity = threshold.intensity_for(estimated)

      CrowdSnapshot.find_or_initialize_by(
        location: location,
        snapshot_date: date,
        hour: hour
      ).update!(
        intensity: intensity,
        estimated_visitors: estimated,
        contributing_ships: ships
      )
    end
  end

  # Which ships contribute to crowd at each location:
  #   The Baths: Spanish Town ships (direct) + Road Town ships (excursion ferry %)
  #   White Bay: Jost Van Dyke ships ONLY (Road Town has no meaningful impact)
  def find_contributing_visits(location, visits)
    result = []

    case location.slug
    when Location::THE_BATHS
      # Spanish Town ships → not all go to The Baths (shops, beach, restaurants too)
      spanish_town_pct = AppConfig.get_float("spanish_town_baths_pct", default: 0.50)
      visits.select { |v| v.port.slug == Port::SPANISH_TOWN }.each do |v|
        result << [v, spanish_town_pct]
      end
      # Gorda Sound ships → tender to Spanish Town, then some go to The Baths
      gorda_sound_pct = AppConfig.get_float("gorda_sound_baths_pct", default: 0.40)
      visits.select { |v| v.port.slug == Port::GORDA_SOUND }.each do |v|
        result << [v, gorda_sound_pct]
      end
      # Road Town ships → excursion ferry percentage to The Baths
      excursion_pct = AppConfig.get_float("road_town_baths_excursion_pct", default: 0.20)
      visits.select { |v| v.port.slug == Port::ROAD_TOWN }.each do |v|
        result << [v, excursion_pct]
      end
    when Location::WHITE_BAY
      # Only Jost Van Dyke ships impact White Bay
      visits.select { |v| v.port.slug == Port::JOST_VAN_DYKE }.each do |v|
        result << [v, 1.0]
      end
    when Location::CANE_GARDEN_BAY
      # Road Town ships only — it's on Tortola, easy taxi ride
      cgb_pct = AppConfig.get_float("road_town_cgb_pct", default: 0.30)
      visits.select { |v| v.port.slug == Port::ROAD_TOWN }.each do |v|
        result << [v, cgb_pct]
      end

    # USVI — St. Thomas (Charlotte Amalie) locations
    when Location::MAGENS_BAY
      pct = AppConfig.get_float("charlotte_amalie_magens_bay_pct", default: 0.25)
      visits.select { |v| v.port.slug == Port::CHARLOTTE_AMALIE }.each do |v|
        result << [v, pct]
      end
    when Location::COKI_BEACH
      pct = AppConfig.get_float("charlotte_amalie_coki_beach_pct", default: 0.20)
      visits.select { |v| v.port.slug == Port::CHARLOTTE_AMALIE }.each do |v|
        result << [v, pct]
      end
    when Location::NATIONAL_PARK_BEACHES
      pct = AppConfig.get_float("charlotte_amalie_national_park_pct", default: 0.15)
      visits.select { |v| v.port.slug == Port::CHARLOTTE_AMALIE }.each do |v|
        result << [v, pct]
      end

    # USVI — St. Croix (Frederiksted) locations
    when Location::RAINBOW_BEACH
      pct = AppConfig.get_float("frederiksted_rainbow_beach_pct", default: 0.40)
      visits.select { |v| v.port.slug == Port::FREDERIKSTED }.each do |v|
        result << [v, pct]
      end
    when Location::BUCK_ISLAND
      pct = AppConfig.get_float("frederiksted_buck_island_pct", default: 0.15)
      visits.select { |v| v.port.slug == Port::FREDERIKSTED }.each do |v|
        result << [v, pct]
      end
    end

    result
  end

  def estimate_visitors_at_hour(visit, location, hour, contribution_pct)
    return 0 unless visit.passenger_capacity && visit.passenger_capacity > 0

    capacity_pct = AppConfig.get_float("capacity_utilization_pct", default: 0.85)
    effective_pax = (visit.passenger_capacity * capacity_pct * contribution_pct).round

    transit_minutes = transit_time_for(visit, location)

    arrival_minutes = arrival_minutes_bvi(visit)
    departure_minutes = departure_minutes_bvi(visit)

    # Default arrival: 6:00 AM if not provided
    arrival_minutes ||= 6 * 60
    # Default departure: 6:00 PM if not provided
    departure_minutes ||= 18 * 60

    # Earliest possible crowd start: ship arrival + transit time to get there
    earliest_from_ship = arrival_minutes + transit_minutes

    # But excursions don't run before the attraction opens
    earliest_open = EARLIEST_EXCURSION_HOURS[location.slug] || 9 * 60
    crowd_start = [earliest_from_ship, earliest_open].max

    # Ramp up over 60 minutes after crowd_start
    ramp_up_end = crowd_start + 60

    # Passengers must LEAVE the attraction ~2 hours before ship departure
    # to get back to the ship in time (tender, ferry, taxi, etc.)
    crowd_end = departure_minutes - RETURN_TO_SHIP_BUFFER_MINUTES

    # Ramp down starts 60 minutes before they need to leave
    ramp_down_start = crowd_end - 60

    # If the math doesn't make sense (ship isn't in port long enough), skip
    return 0 if crowd_end <= crowd_start

    # Hour boundaries in minutes from midnight
    hour_start = hour * 60
    hour_end = (hour + 1) * 60

    # Outside the crowd window entirely
    return 0 if hour_end <= crowd_start || hour_start >= crowd_end

    # Calculate average presence for this hour using trapezoidal model
    mid_point = (hour_start + hour_end) / 2.0

    factor = if mid_point < crowd_start
              0.0
            elsif mid_point < ramp_up_end
              (mid_point - crowd_start) / (ramp_up_end - crowd_start).to_f
            elsif mid_point < ramp_down_start
              1.0
            elsif mid_point < crowd_end
              (crowd_end - mid_point) / (crowd_end - ramp_down_start).to_f
            else
              0.0
            end

    (effective_pax * factor.clamp(0.0, 1.0)).round
  end

  def transit_time_for(visit, location)
    case [visit.port.slug, location.slug]
    when [Port::SPANISH_TOWN, Location::THE_BATHS]
      AppConfig.get_int("transit_time_baths_from_virgin_gorda", default: 90)
    when [Port::GORDA_SOUND, Location::THE_BATHS]
      AppConfig.get_int("transit_time_baths_from_gorda_sound", default: 120)
    when [Port::ROAD_TOWN, Location::THE_BATHS]
      AppConfig.get_int("transit_time_baths_from_road_town", default: 120)
    when [Port::JOST_VAN_DYKE, Location::WHITE_BAY]
      AppConfig.get_int("transit_time_white_bay_from_jost", default: 20)
    when [Port::ROAD_TOWN, Location::CANE_GARDEN_BAY]
      AppConfig.get_int("transit_time_cgb_from_road_town", default: 45)
    # USVI
    when [Port::CHARLOTTE_AMALIE, Location::MAGENS_BAY]
      AppConfig.get_int("transit_time_magens_bay", default: 30)
    when [Port::CHARLOTTE_AMALIE, Location::COKI_BEACH]
      AppConfig.get_int("transit_time_coki_beach", default: 30)
    when [Port::CHARLOTTE_AMALIE, Location::NATIONAL_PARK_BEACHES]
      AppConfig.get_int("transit_time_national_park_beaches", default: 90)
    when [Port::FREDERIKSTED, Location::RAINBOW_BEACH]
      AppConfig.get_int("transit_time_rainbow_beach", default: 5)
    when [Port::FREDERIKSTED, Location::BUCK_ISLAND]
      AppConfig.get_int("transit_time_buck_island", default: 60)
    else
      60
    end
  end

  def arrival_minutes_bvi(visit)
    return nil unless visit.arrival_at
    t = visit.arrival_at.in_time_zone(BVI_TIMEZONE)
    minutes = t.hour * 60 + t.min
    # 23:59 and 11:59 are "time unknown" markers from schedule sources — treat as nil
    return nil if minutes >= 23 * 60 + 50
    return nil if minutes == 11 * 60 + 59
    minutes
  end

  def departure_minutes_bvi(visit)
    return nil unless visit.departure_at
    t = visit.departure_at.in_time_zone(BVI_TIMEZONE)
    t.hour * 60 + t.min
  end
end
