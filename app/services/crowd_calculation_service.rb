class CrowdCalculationService
  BVI_TIMEZONE = "America/Virgin".freeze
  HOURS_RANGE = (7..17).freeze

  # Base time passengers need at the port before departure (boarding, security, etc.)
  # Actual buffer = transit_time + BASE_RETURN_BUFFER so close beaches stay busy longer.
  # Excursions are scheduled against the ship's sailing time, so an hour of slack on
  # top of a full transit leg double-counted and emptied beaches too early.
  BASE_RETURN_BUFFER_MINUTES = 30

  # Ramp durations control how quickly crowds build and disperse.
  # Longer ramps = more realistic gradual buildup/taper.
  DEFAULT_RAMP_UP_MINUTES = 90
  DEFAULT_RAMP_DOWN_MINUTES = 120

  # Presence is averaged over each hour at 5-minute resolution.
  SAMPLES_PER_HOUR = 12

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
      # JVD ships anchor directly — full impact
      visits.select { |v| v.port.slug == Port::JOST_VAN_DYKE }.each do |v|
        result << [v, 1.0]
      end
      # Road Town ships — some passengers water taxi to White Bay. Small % but noticeable.
      # Similar timing to The Baths (ferry + taxi). Kept low so it stays moderate, not red.
      white_bay_from_rt_pct = AppConfig.get_float("road_town_white_bay_pct", default: 0.05)
      visits.select { |v| v.port.slug == Port::ROAD_TOWN }.each do |v|
        result << [v, white_bay_from_rt_pct]
      end
    when Location::CANE_GARDEN_BAY
      # Road Town ships only — it's on Tortola, easy taxi ride
      cgb_pct = AppConfig.get_float("road_town_cgb_pct", default: 0.30)
      visits.select { |v| v.port.slug == Port::ROAD_TOWN }.each do |v|
        result << [v, cgb_pct]
      end

    # USVI — St. Thomas (Charlotte Amalie) locations
    when Location::MAGENS_BAY
      pct = AppConfig.get_float("charlotte_amalie_magens_bay_pct", default: 0.10)
      visits.select { |v| v.port.slug == Port::CHARLOTTE_AMALIE }.each do |v|
        result << [v, pct]
      end
    when Location::COKI_BEACH
      pct = AppConfig.get_float("charlotte_amalie_coki_beach_pct", default: 0.10)
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
    aboard = passengers_aboard(visit)
    return 0 unless aboard&.positive?

    effective_pax = (aboard * contribution_pct).round

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

    # Ramp up gradually — crowds don't all arrive at once
    ramp_up_minutes = AppConfig.get_int("ramp_up_minutes", default: DEFAULT_RAMP_UP_MINUTES)

    # Passengers must LEAVE the attraction in time to get back to the ship.
    # Close beaches (30 min taxi) → people stay later. Far destinations (90 min ferry) → leave earlier.
    return_buffer = transit_minutes + BASE_RETURN_BUFFER_MINUTES
    crowd_end = departure_minutes - return_buffer

    # Ramp down gradually — people leave at staggered times
    ramp_down_minutes = AppConfig.get_int("ramp_down_minutes", default: DEFAULT_RAMP_DOWN_MINUTES)

    # If the math doesn't make sense (ship isn't in port long enough), skip
    return 0 if crowd_end <= crowd_start

    # Short port stays can't fit the full ramps. Without this the ramps overlap,
    # the trapezoid inverts, and the crowd never reaches its true peak — a 2.5hr
    # window was being modelled with 3.5hrs of ramp. Cap each at a third of the
    # window so there is always a genuine plateau in between.
    window = crowd_end - crowd_start
    ramp_up_minutes = [ramp_up_minutes, window / 3].min
    ramp_down_minutes = [ramp_down_minutes, window / 3].min

    ramp_up_end = crowd_start + ramp_up_minutes
    ramp_down_start = crowd_end - ramp_down_minutes

    # Hour boundaries in minutes from midnight
    hour_start = hour * 60
    hour_end = (hour + 1) * 60

    # Outside the crowd window entirely
    return 0 if hour_end <= crowd_start || hour_start >= crowd_end

    # Average presence ACROSS the hour, not at a single instant. Sampling only the
    # midpoint threw away any window that opened or closed mid-hour: a ship whose
    # crowd cleared at 13:30 scored 0 for the 13:00 hour even with hundreds of
    # people on the beach until 13:29, producing green hours between busy ones.
    step = 60.0 / SAMPLES_PER_HOUR
    total = (0...SAMPLES_PER_HOUR).sum do |i|
      at = hour_start + (i + 0.5) * step
      presence_factor(at, crowd_start, ramp_up_end, ramp_down_start, crowd_end)
    end

    (effective_pax * (total / SAMPLES_PER_HOUR)).round
  end

  # Trapezoid: ramp up from crowd_start, plateau, ramp down to crowd_end.
  def presence_factor(at, crowd_start, ramp_up_end, ramp_down_start, crowd_end)
    factor = if at < crowd_start
              0.0
            elsif at < ramp_up_end
              (at - crowd_start) / (ramp_up_end - crowd_start).to_f
            elsif at < ramp_down_start
              1.0
            elsif at < crowd_end
              (crowd_end - at) / (crowd_end - ramp_down_start).to_f
            else
              0.0
            end

    factor.clamp(0.0, 1.0)
  end

  # PortCall reports the passengers actually expected on board. Everything else
  # reports maximum capacity, which has to be discounted to a realistic load —
  # applying that discount to an already-realistic figure would double-count it.
  def passengers_aboard(visit)
    return visit.expected_passengers if visit.expected_passengers.to_i.positive?
    return nil unless visit.passenger_capacity.to_i.positive?

    (visit.passenger_capacity * AppConfig.get_float("capacity_utilization_pct", default: 0.85)).round
  end

  def transit_time_for(visit, location)
    case [visit.port.slug, location.slug]
    when [Port::SPANISH_TOWN, Location::THE_BATHS]
      AppConfig.get_int("transit_time_baths_from_virgin_gorda", default: 30)
    when [Port::GORDA_SOUND, Location::THE_BATHS]
      AppConfig.get_int("transit_time_baths_from_gorda_sound", default: 60)
    when [Port::ROAD_TOWN, Location::THE_BATHS]
      AppConfig.get_int("transit_time_baths_from_road_town", default: 60)
    when [Port::JOST_VAN_DYKE, Location::WHITE_BAY]
      AppConfig.get_int("transit_time_white_bay_from_jost", default: 20)
    when [Port::ROAD_TOWN, Location::WHITE_BAY]
      AppConfig.get_int("transit_time_white_bay_from_road_town", default: 45)
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

  # Minutes from midnight on the VISIT date, so an overnight call departing at
  # 02:00 the next day reads as 1560, not 120. Returning the raw clock time would
  # push crowd_end negative and silently drop the ship from the forecast.
  def departure_minutes_bvi(visit)
    return nil unless visit.departure_at
    t = visit.departure_at.in_time_zone(BVI_TIMEZONE)
    minutes = t.hour * 60 + t.min
    # Same "time unknown" markers the sources use on arrivals — fall back to the default
    return nil if minutes >= 23 * 60 + 50

    minutes + ((t.to_date - visit.visit_date).to_i * 1440)
  end
end
