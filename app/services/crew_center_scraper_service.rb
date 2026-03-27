class CrewCenterScraperService
  BASE_URL = "https://crew-center.com".freeze

  PORT_PATHS = {
    "road-town" => "/road-town-tortola-bvi-cruise-ship-schedule",
    "spanish-town" => "/virgin-gorda-spanish-town-bvi-cruise-ship-schedule",
    "jost-van-dyke" => "/jost-van-dyke-bvi-cruise-ship-schedule",
    "norman-island" => "/norman-island-bvi-cruise-ships-schedule"
  }.freeze

  def self.fetch_all
    new.fetch_all
  end

  def fetch_all
    results = []

    PORT_PATHS.each do |port_slug, path|
      port = Port.find_by!(slug: port_slug)
      visits = fetch_port(port, path)
      results.concat(visits)
      sleep 1.5 # Be polite
    end

    results
  end

  private

  def fetch_port(port, path)
    url = "#{BASE_URL}#{path}"
    response = HTTParty.get(url, headers: { "User-Agent" => user_agent }, timeout: 30)

    raise "HTTP #{response.code} for #{url}" unless response.success?

    doc = Nokogiri::HTML(response.body)
    tables = doc.css("table.cruidedig-schedule")

    return [] if tables.empty?

    arrivals = parse_table(tables[0])
    departures = parse_table(tables[1]) if tables.length > 1

    merge_arrivals_departures(arrivals, departures || {}, port)
  end

  def parse_table(table)
    results = {}

    table.css("tbody tr").each do |row|
      ship_td = row.at_css("td.ship")
      time_td = row.css("td")[1]

      next unless ship_td && time_td

      ship_name = extract_ship_name(ship_td)
      next if ship_name.blank?

      smalls = ship_td.css("small")
      cruise_line = smalls[0]&.text&.strip
      passengers_raw = smalls[1]&.text&.strip
      passengers = parse_european_number(passengers_raw)

      datetime_str = time_td.text.strip
      datetime = parse_datetime(datetime_str)

      results[ship_name] = {
        cruise_line: cruise_line,
        passenger_capacity: passengers,
        datetime: datetime,
        datetime_raw: datetime_str
      }
    end

    results
  end

  def extract_ship_name(td)
    # Ship name is the first text node before any <small> tags
    td.children.each do |child|
      if child.text? && child.text.strip.present?
        return child.text.strip
      end
    end
    nil
  end

  def parse_european_number(raw)
    return nil if raw.blank?
    # "2.198 passengers" → 2198
    # European decimal uses period as thousands separator
    raw.gsub(/[^\d.]/, "").gsub(".", "").to_i.then { |n| n > 0 ? n : nil }
  end

  def parse_datetime(str)
    return nil if str.blank?
    # "28 Mar 2026 - 08:00" — times are BVI local (AST = UTC-4)
    Time.use_zone("America/Virgin") do
      Time.zone.strptime(str, "%d %b %Y - %H:%M")
    end
  rescue ArgumentError
    nil
  end

  def merge_arrivals_departures(arrivals, departures, port)
    results = []

    arrivals.each do |ship_name, arrival_data|
      departure_data = departures[ship_name]

      arrival_dt = arrival_data[:datetime]
      departure_dt = departure_data&.dig(:datetime)
      visit_date = arrival_dt&.to_date

      next unless visit_date

      # Look up capacity from reference if not scraped
      capacity = arrival_data[:passenger_capacity]
      capacity_estimated = false

      if capacity.nil? || capacity == 0
        capacity = ShipCapacityLookup.find(ship_name)
        capacity_estimated = capacity.present?
      end

      results << {
        port_id: port.id,
        ship_name: ship_name,
        cruise_line: arrival_data[:cruise_line],
        passenger_capacity: capacity,
        arrival_at: arrival_dt,
        departure_at: departure_dt,
        visit_date: visit_date,
        source: "crew_center",
        capacity_estimated: capacity_estimated
      }
    end

    results
  end

  def user_agent
    "Mozilla/5.0 (compatible; BVICruiseTracker/1.0)"
  end
end
