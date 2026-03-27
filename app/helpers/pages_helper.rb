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

  def contributing_port?(visit, location)
    case location.slug
    when Location::THE_BATHS
      visit.port.slug.in?([Port::SPANISH_TOWN, Port::ROAD_TOWN])
    when Location::WHITE_BAY
      visit.port.slug == Port::JOST_VAN_DYKE
    else
      false
    end
  end
end
