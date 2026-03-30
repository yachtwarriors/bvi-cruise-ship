class CruiseDigScraperService
  BASE_URL = "https://cruisedig.com".freeze

  PORT_PATHS = {
    # BVI
    "road-town" => "/ports/tortola-british-virgin-islands/arrivals",
    "spanish-town" => "/ports/virgin-gorda-british-virgin-islands/arrivals",
    "jost-van-dyke" => "/ports/jost-van-dyke-british-virgin-islands/arrivals",
    "norman-island" => "/ports/norman-island-british-virgin-islands/arrivals",
    "gorda-sound" => "/ports/gorda-sound-british-virgin-islands/arrivals",
    # USVI
    "charlotte-amalie" => "/ports/charlotte-amalie-us-virgin-islands/arrivals",
    "frederiksted" => "/ports/frederiksted-us-virgin-islands/arrivals"
  }.freeze

  MAX_PAGES = 20

  def self.fetch_all
    new.fetch_all
  end

  def fetch_all
    results = []

    PORT_PATHS.each do |port_slug, path|
      port = Port.find_by!(slug: port_slug)
      visits = fetch_port(port, path)
      results.concat(visits)
      sleep 1.5
    end

    results
  end

  private

  def fetch_port(port, path)
    results = []
    page = 0

    loop do
      break if page >= MAX_PAGES

      url = "#{BASE_URL}#{path}?page=#{page}"
      response = HTTParty.get(url, headers: { "User-Agent" => user_agent }, timeout: 30)

      break unless response.success?

      doc = Nokogiri::HTML(response.body)
      entries = parse_page(doc, port)

      break if entries.empty?

      results.concat(entries)
      page += 1

      # Check if there's a next page
      break unless doc.at_css("li.pager__item--next a, a[rel='next']")

      sleep 1.5
    end

    results
  end

  def parse_page(doc, port)
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
      arrival_at = parse_datetime(datetime_text)
      visit_date = arrival_at&.to_date

      next unless visit_date

      capacity = passengers
      capacity_estimated = false
      if capacity.nil? || capacity == 0
        capacity = ShipCapacityLookup.find(ship_name)
        capacity_estimated = capacity.present?
      end

      results << {
        port_id: port.id,
        ship_name: ship_name,
        cruise_line: cruise_line,
        passenger_capacity: capacity,
        arrival_at: arrival_at,
        departure_at: nil, # CruiseDig arrivals page doesn't have departure times
        visit_date: visit_date,
        source: "cruisedig",
        capacity_estimated: capacity_estimated
      }
    end

    results
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
