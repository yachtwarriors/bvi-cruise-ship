class CruiseDigScraperService
  BASE_URL = "https://cruisedig.com".freeze

  PORT_PATHS = {
    "road-town" => "/ports/tortola-british-virgin-islands/arrivals",
    "spanish-town" => "/ports/virgin-gorda-british-virgin-islands/arrivals",
    "jost-van-dyke" => "/ports/jost-van-dyke-british-virgin-islands/arrivals",
    "norman-island" => "/ports/norman-island-british-virgin-islands/arrivals"
  }.freeze

  MAX_PAGES = 20 # Safety limit

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
      break unless doc.at_css("a[rel='next']") || doc.css(".pager__item--next a").any?

      sleep 1.5
    end

    results
  end

  def parse_page(doc, port)
    results = []

    # CruiseDig uses <li> elements in a list, not tables
    doc.css(".view-content .views-row, .view-content li").each do |entry|
      text = entry.text.strip
      next if text.blank?

      # Try to extract ship name, cruise line, passengers, date from the entry
      parsed = parse_entry(entry)
      next unless parsed && parsed[:visit_date]

      capacity = parsed[:passenger_capacity]
      capacity_estimated = false

      if capacity.nil? || capacity == 0
        capacity = ShipCapacityLookup.find(parsed[:ship_name])
        capacity_estimated = capacity.present?
      end

      results << {
        port_id: port.id,
        ship_name: parsed[:ship_name],
        cruise_line: parsed[:cruise_line],
        passenger_capacity: capacity,
        arrival_at: parsed[:arrival_at],
        departure_at: parsed[:departure_at],
        visit_date: parsed[:visit_date],
        source: "cruisedig",
        capacity_estimated: capacity_estimated
      }
    end

    results
  end

  def parse_entry(entry)
    # CruiseDig entries have links for ship and cruise line, plus text for date/pax
    ship_link = entry.at_css("a[href*='/cruise-ships/'], a[href*='/ship/']")
    line_link = entry.at_css("a[href*='/cruise-lines/'], a[href*='/line/']")

    ship_name = ship_link&.text&.strip
    return nil if ship_name.blank?

    cruise_line = line_link&.text&.strip

    # Extract passenger count — look for number followed by "passengers" or "pax"
    pax_match = entry.text.match(/(\d[\d.,]*)\s*(?:passengers|pax)/i)
    passengers = pax_match ? pax_match[1].gsub(/[,.]/, "").to_i : nil

    # Extract date — look for common date patterns
    date_match = entry.text.match(/(\d{1,2}\s+\w{3}\s+\d{4})/)
    if date_match
      visit_date = Date.parse(date_match[1]) rescue nil
    end

    # Extract time if present
    time_match = entry.text.match(/(\d{2}:\d{2})/)
    arrival_at = nil
    if time_match && visit_date
      arrival_at = DateTime.parse("#{visit_date} #{time_match[1]}")
    end

    return nil unless visit_date

    {
      ship_name: ship_name,
      cruise_line: cruise_line,
      passenger_capacity: passengers,
      arrival_at: arrival_at,
      departure_at: nil,
      visit_date: visit_date
    }
  end

  def user_agent
    "Mozilla/5.0 (compatible; BVICruiseTracker/1.0)"
  end
end
