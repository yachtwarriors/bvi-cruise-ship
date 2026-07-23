class CruiseDigScraperService
  BASE_URL = "https://cruisedig.com".freeze

  PORT_PATHS = {
    # BVI
    "road-town" => "/ports/tortola-british-virgin-islands",
    "spanish-town" => "/ports/virgin-gorda-british-virgin-islands",
    "jost-van-dyke" => "/ports/jost-van-dyke-british-virgin-islands",
    "norman-island" => "/ports/norman-island-british-virgin-islands",
    "gorda-sound" => "/ports/gorda-sound-british-virgin-islands",
    # USVI
    "charlotte-amalie" => "/ports/st-thomas-us-virgin-islands",
    "frederiksted" => "/ports/st-croix-us-virgin-islands"
  }.freeze

  MAX_PAGES = 20

  # A departure belongs to an arrival if it falls within this window after it.
  # Covers same-day calls and overnight stays without pairing across separate visits.
  MAX_PORT_STAY_HOURS = 36

  def self.fetch_all
    new.fetch_all
  end

  def fetch_all
    results = []

    PORT_PATHS.each do |port_slug, base_path|
      port = Port.find_by!(slug: port_slug)
      visits = fetch_port(port, base_path)
      results.concat(visits)
      sleep 1.5
    end

    results
  end

  private

  # Arrivals and departures live on separate pages with identical markup.
  # Fetch both and pair them up so we get a real port-stay window per visit.
  def fetch_port(port, base_path)
    arrivals = fetch_listing("#{base_path}/arrivals")
    sleep 1.5
    departures = fetch_listing("#{base_path}/departures")

    merge_arrivals_departures(arrivals, departures, port)
  end

  def fetch_listing(path)
    results = []
    page = 0

    loop do
      break if page >= MAX_PAGES

      url = "#{BASE_URL}#{path}?page=#{page}"
      response = HTTParty.get(url, headers: { "User-Agent" => user_agent }, timeout: 30)

      break unless response.success?

      doc = Nokogiri::HTML(response.body)
      entries = parse_page(doc)

      break if entries.empty?

      results.concat(entries)
      page += 1

      # Check if there's a next page
      break unless doc.at_css("li.pager__item--next a, a[rel='next']")

      sleep 1.5
    end

    results
  end

  # Returns raw timetable entries. The same markup backs both the arrivals and
  # departures pages, so the caller decides what :datetime means.
  def parse_page(doc)
    results = []

    doc.css(".view-content li").each do |li|
      schedule = li.at_css(".schedule")
      next unless schedule

      ship_div = schedule.at_css(".schedule__ship")
      datetime_div = schedule.at_css(".schedule__datetime")
      next unless ship_div && datetime_div

      # Ship name from the first link in .name
      ship_name = ship_div.at_css(".name a")&.text&.strip
      next if ship_name.blank?

      # Cruise line from the first .occupancy link
      cruise_line = ship_div.at_css(".occupancy a")&.text&.strip

      # Passenger count from .occupancy text containing "passengers"
      pax_div = ship_div.css(".occupancy").find { |d| d.text.include?("passengers") }
      passengers = parse_european_number(pax_div&.text)

      # Date and time
      datetime_text = datetime_div.text.gsub(/\s+/, " ").strip
      datetime = parse_datetime(datetime_text)

      next unless datetime

      capacity = passengers
      capacity_estimated = false
      if capacity.nil? || capacity == 0
        capacity = ShipCapacityLookup.find(ship_name)
        capacity_estimated = capacity.present?
      end

      results << {
        ship_name: ship_name,
        cruise_line: cruise_line,
        passenger_capacity: capacity,
        capacity_estimated: capacity_estimated,
        datetime: datetime
      }
    end

    results
  end

  # Pair each arrival with the first departure for that ship that falls after it
  # and within MAX_PORT_STAY_HOURS. Departures are consumed once so a ship calling
  # twice in one week doesn't borrow the wrong sailing time.
  def merge_arrivals_departures(arrivals, departures, port)
    by_ship = departures.group_by { |d| d[:ship_name] }
    by_ship.each_value { |list| list.sort_by! { |d| d[:datetime] } }
    used = Hash.new { |h, k| h[k] = [] }

    arrivals.sort_by { |a| a[:datetime] }.map do |arrival|
      arrival_at = arrival[:datetime]
      candidates = by_ship[arrival[:ship_name]] || []

      match = candidates.find do |d|
        next false if used[arrival[:ship_name]].include?(d.object_id)
        d[:datetime] >= arrival_at && d[:datetime] <= arrival_at + MAX_PORT_STAY_HOURS.hours
      end
      used[arrival[:ship_name]] << match.object_id if match
      departure_at = match&.dig(:datetime)
      departure_at = nil if unknown_time?(departure_at)

      {
        port_id: port.id,
        ship_name: arrival[:ship_name],
        cruise_line: arrival[:cruise_line],
        passenger_capacity: arrival[:passenger_capacity],
        arrival_at: arrival_at,
        departure_at: departure_at,
        visit_date: arrival_at.to_date,
        source: "cruisedig",
        capacity_estimated: arrival[:capacity_estimated]
      }
    end
  end

  # CruiseDig writes 23:59 when it has the date but not the clock time.
  # Storing that literally would render as a real late-night sailing.
  def unknown_time?(time)
    return false if time.nil?
    time.hour * 60 + time.min >= 23 * 60 + 50
  end

  def parse_european_number(raw)
    return nil if raw.blank?
    raw.gsub(/[^\d.]/, "").gsub(".", "").to_i.then { |n| n > 0 ? n : nil }
  end

  def parse_datetime(str)
    return nil if str.blank?
    # "28 Mar 2026 - 08:00" — times are BVI local (AST = UTC-4)
    Time.use_zone("America/Virgin") do
      Time.zone.strptime(str, "%d %b %Y - %H:%M")
    end
  rescue ArgumentError
    # Try without time
    begin
      Date.strptime(str.split(" - ").first.strip, "%d %b %Y").in_time_zone("America/Virgin")
    rescue
      nil
    end
  end

  def user_agent
    "Mozilla/5.0 (compatible; BVICruiseTracker/1.0)"
  end
end
