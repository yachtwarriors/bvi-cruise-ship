module ApplicationHelper
  BVI_TIMEZONE = "America/Virgin".freeze

  # Schedule sources use 23:59 (and occasionally 11:59) to mean "date known,
  # time unknown". Rendering those literally would show a ship sailing at
  # midnight, so they read as unknown instead.
  def local_ship_time(time)
    return nil if time.blank?

    local = time.in_time_zone(BVI_TIMEZONE)
    minutes = local.hour * 60 + local.min
    return nil if minutes >= 23 * 60 + 50
    return nil if minutes == 11 * 60 + 59

    local.strftime("%-l:%M%P").sub(":00", "")
  end

  # "6:45am–2pm" for a full call, "6:45am–?" when the sailing time is unknown.
  # Departure times matter as much as arrivals here: two ships in port on the
  # same day rarely overlap fully, and knowing when the big one leaves is the
  # difference between a packed beach and an empty one.
  def ship_time_window(visit)
    arrival = local_ship_time(visit.arrival_at)
    departure = local_ship_time(visit.departure_at)

    return nil if arrival.nil? && departure.nil?

    "#{arrival || '?'}–#{departure || '?'}"
  end
end
