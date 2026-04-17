module PagesHelper
  def intensity_color_class(intensity)
    case intensity
    when "green" then "bg-emerald-400"
    when "yellow" then "bg-amber-400"
    when "red" then "bg-red-500"
    else "bg-gray-200"
    end
  end

  def intensity_text_color(intensity)
    case intensity
    when "green" then "text-emerald-700"
    when "yellow" then "text-amber-700"
    when "red" then "text-red-700"
    else "text-gray-500"
    end
  end

  def intensity_bg_light(intensity)
    case intensity
    when "green" then "bg-emerald-50"
    when "yellow" then "bg-amber-50"
    when "red" then "bg-red-50"
    else "bg-gray-50"
    end
  end

  def intensity_border_class(intensity)
    case intensity
    when "green" then "border-l-emerald-400"
    when "yellow" then "border-l-amber-400"
    when "red" then "border-l-red-500"
    else "border-l-slate-200"
    end
  end

  def intensity_label(intensity)
    case intensity
    when "green" then "Low"
    when "yellow" then "Moderate"
    when "red" then "High"
    else "—"
    end
  end

  # Summary stats for a week view — used by the weekly overview strip.
  # Returns { passengers:, ships:, busiest_date:, busiest_peak: } or nil if no visits.
  def week_overview_stats(dates, visits_by_date, locations, snapshots)
    all_visits = dates.flat_map { |d| visits_by_date[d] || [] }
    return nil if all_visits.empty?

    busiest_date = dates.max_by { |d| total_passengers_for(visits_by_date[d] || []) }
    {
      passengers: all_visits.sum { |v| v.passenger_capacity || 0 },
      ships: all_visits.size,
      busiest_date: busiest_date,
      busiest_peak: day_peak_intensity(busiest_date, locations, snapshots)
    }
  end

  def peak_intensity_for(snapshots)
    return "green" if snapshots.blank?
    priorities = { "red" => 3, "yellow" => 2, "green" => 1 }
    snapshots.max_by { |s| priorities[s.intensity] || 0 }&.intensity || "green"
  end

  def total_passengers_for(visits)
    visits.sum { |v| v.passenger_capacity || 0 }
  end

  def ships_summary(visits)
    by_port = visits.group_by { |v| v.port.name }
    by_port.map { |port, vs| "#{vs.size} at #{port.sub(', Tortola', '').sub(', Virgin Gorda', '')} (#{number_with_delimiter(total_passengers_for(vs))} pax)" }.join(" · ")
  end

  def format_time_bvi(datetime)
    return "—" unless datetime
    datetime.in_time_zone("America/Virgin").strftime("%-I:%M %p")
  end

  def format_hour(hour)
    if hour == 0 || hour == 12
      hour == 0 ? "12:00 AM" : "12:00 PM"
    elsif hour < 12
      "#{hour}:00 AM"
    else
      "#{hour - 12}:00 PM"
    end
  end

  def format_hour_short(hour)
    if hour == 12
      "12p"
    elsif hour < 12
      "#{hour}a"
    else
      "#{hour - 12}p"
    end
  end

  def day_peak_intensity(date, locations, snapshots)
    locations.map { |loc|
      peak_intensity_for(snapshots[[date, loc.id]] || [])
    }.max_by { |i| { "red" => 3, "yellow" => 2, "green" => 1 }[i] || 0 }
  end

  # Maps each location to the ports whose ships contribute to its crowds
  LOCATION_PORT_MAP = {
    Location::THE_BATHS => [Port::SPANISH_TOWN, Port::ROAD_TOWN, Port::GORDA_SOUND],
    Location::WHITE_BAY => [Port::JOST_VAN_DYKE],
    Location::CANE_GARDEN_BAY => [Port::ROAD_TOWN],
    Location::MAGENS_BAY => [Port::CHARLOTTE_AMALIE],
    Location::COKI_BEACH => [Port::CHARLOTTE_AMALIE],
    Location::NATIONAL_PARK_BEACHES => [Port::CHARLOTTE_AMALIE],
    Location::RAINBOW_BEACH => [Port::FREDERIKSTED],
    Location::BUCK_ISLAND => [Port::FREDERIKSTED],
  }.freeze

  def contributing_port?(visit, location)
    ports = LOCATION_PORT_MAP[location.slug]
    ports ? visit.port.slug.in?(ports) : false
  end

  # Inverse: given a location slug, return the port slugs that send crowds there
  def contributing_port_slugs_for(location_slug)
    LOCATION_PORT_MAP[location_slug] || []
  end
end
