class HistoricalScraperService
  BASE_URL = "https://crew-center.com".freeze

  # Archive URL patterns vary by year
  ARCHIVE_URLS = {
    2017 => "/tortola-cruise-ship-schedule-2017",
    2018 => "/tortola-cruise-ship-schedule-2018",
    2019 => "/tortola-bvi-cruise-ship-schedule-2019",
    2020 => "/road-town-tortola-bvi-cruise-ship-schedule-2020",
    2021 => "/british-virgin-islands-cruise-ports-schedules-2021"
  }.freeze

  def self.fetch_year(year)
    new.fetch_year(year)
  end

  def self.fetch_all_years
    new.fetch_all_years
  end

  def fetch_all_years
    total = 0
    ARCHIVE_URLS.each do |year, path|
      count = fetch_year(year)
      total += count
      puts "  #{year}: #{count} visits"
      sleep 2
    end
    total
  end

  def fetch_year(year)
    path = ARCHIVE_URLS[year]
    return 0 unless path

    url = "#{BASE_URL}#{path}"
    response = HTTParty.get(url, headers: { "User-Agent" => user_agent }, timeout: 30)

    unless response.success?
      puts "  #{year}: HTTP #{response.code}"
      return 0
    end

    doc = Nokogiri::HTML(response.body)
    visits = parse_archive_table(doc, year)
    persist_visits(visits)
  end

  private

  def parse_archive_table(doc, year)
    results = []
    road_town = Port.find_by!(slug: "road-town")

    doc.css("table").each do |table|
      rows = table.css("tr")
      next if rows.empty?

      # Check if this looks like a schedule table (has Port/Date/Ship headers)
      header_text = rows.first.text.downcase
      next unless header_text.include?("port") || header_text.include?("date") || header_text.include?("ship")

      rows[1..].each do |row|
        cells = row.css("td")
        next if cells.length < 4

        # Format: Port | Date | Cruise Ship | Cruise Line | Arrival – Depart
        port_name = cells[0]&.text&.strip
        date_str = cells[1]&.text&.strip
        ship_name = cells[2]&.text&.strip
        cruise_line = cells[3]&.text&.strip
        times_str = cells[4]&.text&.strip if cells.length >= 5

        next if ship_name.blank? || date_str.blank?

        # Parse date — format: "31-Dec-2017" or "2-Jan-2018"
        visit_date = parse_date(date_str, year)
        next unless visit_date

        # Parse arrival/departure times — format: "08:00 - 19:00" or "08:00-18:00" or "n/a"
        arrival_at, departure_at = parse_times(times_str, visit_date)

        # Look up passenger capacity from reference
        capacity = ShipCapacityLookup.find(ship_name)

        # Determine port — archive pages are Tortola-only (Road Town)
        port = road_town

        results << {
          port_id: port.id,
          ship_name: ship_name,
          cruise_line: cruise_line,
          passenger_capacity: capacity,
          arrival_at: arrival_at,
          departure_at: departure_at,
          visit_date: visit_date,
          source: "archive_#{visit_date.year}",
          capacity_estimated: capacity.present?
        }
      end
    end

    results
  end

  def parse_date(str, fallback_year)
    # "31-Dec-2017" or "2-Jan-2018"
    Date.parse(str)
  rescue Date::Error, ArgumentError
    nil
  end

  def parse_times(str, visit_date)
    return [nil, nil] if str.blank? || str.downcase.include?("n/a")

    # "08:00 - 19:00" or "08:00-18:00" or "08:00 - 19:00"
    parts = str.split(/\s*[-–]\s*/)
    arrival_at = parse_time(parts[0], visit_date)
    departure_at = parse_time(parts[1], visit_date) if parts.length > 1

    [arrival_at, departure_at]
  end

  def parse_time(str, visit_date)
    return nil if str.blank? || str.downcase.include?("n/a")
    Time.use_zone("America/Virgin") do
      Time.zone.parse("#{visit_date} #{str.strip}")
    end
  rescue ArgumentError
    nil
  end

  def persist_visits(visits)
    count = 0
    visits.each do |attrs|
      visit = CruiseVisit.find_or_initialize_by(
        ship_name: attrs[:ship_name],
        visit_date: attrs[:visit_date],
        port_id: attrs[:port_id]
      )
      if visit.new_record?
        visit.assign_attributes(attrs)
        visit.save!
        count += 1
      end
    end
    count
  end

  def user_agent
    "Mozilla/5.0 (compatible; BVICruiseTracker/1.0)"
  end
end
