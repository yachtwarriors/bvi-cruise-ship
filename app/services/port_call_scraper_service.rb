# BVI Ports Authority's own berth scheduling system (PortCall). This is the
# operator's operational record rather than an aggregator's copy of it, so it is
# the authoritative source for BVI: real expected passenger counts, departure
# times on every call, berth-level detail, and explicit -04:00 offsets.
#
# One unauthenticated request returns the entire schedule. The public site's
# ?date= and #! parameters are client-side filters only — the response is
# always identical — so there is nothing to paginate.
class PortCallScraperService
  ENDPOINT = "https://bvi.portcall.com/PortCallServer/portcall/app/home/cruise/1".freeze
  BVI_TIMEZONE = "America/Virgin".freeze

  # Passengers cannot walk off the moment the ship ties up: clearance, gangway,
  # then the first groups. PortCall records berth time, while the aggregators
  # publish guest-facing times. Berth + 60 puts a 05:30 berthing at 06:30, within
  # 15 minutes of what CruiseDig and CruiseMapper show for the same call.
  GANGWAY_OFFSET_MINUTES = 60
  # And nobody is ashore before this regardless of how early the ship berths.
  EARLIEST_DISEMBARK_MINUTES = 7 * 60

  # Berths map to the ports we already model. Anything unmapped is skipped and
  # logged rather than guessed at — Soper's Hole and Beef Island are nowhere near
  # the Road Town cruise pier, and folding them in would inflate Cane Garden Bay.
  BERTH_PATTERNS = {
    /Cruise Pier|Inner Harbor|Outer Harbor|-RH\b|-CP\b/i => "road-town",
    /\bJVD\b/i => "jost-van-dyke",
    /Spanish Town/i => "spanish-town",
    /Gorda Sound|Mosquito Island/i => "gorda-sound",
    /Norman Island/i => "norman-island"
  }.freeze

  def self.fetch_all
    new.fetch_all
  end

  def fetch_all
    response = HTTParty.get(ENDPOINT, headers: { "User-Agent" => user_agent }, timeout: 45)
    raise "HTTP #{response.code} for #{ENDPOINT}" unless response.success?

    payload = JSON.parse(response.body)
    ports = Port.where(slug: BERTH_PATTERNS.values.uniq).index_by(&:slug)
    skipped = Hash.new(0)
    known_ships = CruiseVisit.distinct.pluck(:ship_name).compact.index_by(&:downcase)

    results = payload.flat_map { |group| group["CruiseVisits"] || [] }.filter_map do |visit|
      build_visit(visit, ports, skipped, known_ships)
    end

    skipped.each { |reason, count| Rails.logger.info("PortCall skipped #{count} records: #{reason}") }
    results
  end

  private

  def build_visit(raw, ports, skipped, known_ships)
    berth = raw["BerthName"].to_s
    slug = port_slug_for(berth)
    if slug.nil?
      skipped["unmapped berth #{berth}"] += 1
      return nil
    end

    port = ports[slug]
    if port.nil?
      skipped["missing port #{slug}"] += 1
      return nil
    end

    berthed_at = parse_time(raw["Arrival"])
    # PortCall misspells the key, and it is their spelling we have to read.
    departure_at = parse_time(raw["Deparature"])

    if berthed_at.nil?
      skipped["unparseable arrival"] += 1
      return nil
    end

    departure_at = nil if unknown_time?(departure_at)
    arrival_at = apply_gangway_offset(berthed_at)

    # Overnight anchorages are sometimes recorded with the departure clock time
    # on the arrival's date, producing a sailing that precedes its own arrival.
    if departure_at && departure_at <= arrival_at
      skipped["departure not after arrival"] += 1
      departure_at = nil
    end

    {
      port_id: port.id,
      ship_name: canonical_ship_name(raw["VesselName"], known_ships),
      cruise_line: nil,
      passenger_capacity: raw["ExpectedPassengerCount"].to_i.positive? ? raw["ExpectedPassengerCount"].to_i : nil,
      # Already a realistic load rather than a maximum, so the crowd model must
      # not discount it again by the capacity utilisation factor.
      expected_passengers: raw["ExpectedPassengerCount"].to_i.positive? ? raw["ExpectedPassengerCount"].to_i : nil,
      arrival_at: arrival_at,
      departure_at: departure_at,
      visit_date: arrival_at.to_date,
      source: "portcall",
      capacity_estimated: false
    }
  end

  # PortCall shouts every vessel name ("MSC OPERA"), and titleize alone turns that
  # into "Msc Opera" — a different string from the "MSC Opera" other sources use.
  # Visits key on ship name, so a mismatch silently creates a second row for the
  # same call and double-counts its passengers on the beach.
  #
  # Reuse the spelling already on file whenever we recognise the ship, and only
  # fall back to formatting rules for genuinely new vessels.
  BRAND_CASINGS = {
    /\AMsc /i => "MSC ",
    /\AAida/i => "AIDA"
  }.freeze
  ROMAN_NUMERAL = /\b(Ii|Iii|Iv|Vi|Vii|Viii|Ix|Xi|Xii)\b/

  def canonical_ship_name(raw_name, known_ships)
    name = raw_name.to_s.strip
    return name if name.empty?

    known = known_ships[name.downcase]
    return known if known

    formatted = name.titleize
    BRAND_CASINGS.each { |pattern, replacement| formatted = formatted.sub(pattern, replacement) }
    formatted = formatted.gsub(ROMAN_NUMERAL) { |m| m.upcase }
    formatted.gsub(/\b(Of|The|And)\b/) { |m| m.downcase }.sub(/\A(\w)/) { $1.upcase }
  end

  def port_slug_for(berth)
    BERTH_PATTERNS.each { |pattern, slug| return slug if berth.match?(pattern) }
    nil
  end

  def apply_gangway_offset(berthed_at)
    ashore = berthed_at + GANGWAY_OFFSET_MINUTES.minutes
    floor = ashore.beginning_of_day + EARLIEST_DISEMBARK_MINUTES.minutes
    [ashore, floor].max
  end

  def unknown_time?(time)
    return true if time.nil?
    time.hour * 60 + time.min >= 23 * 60 + 50
  end

  def parse_time(value)
    return nil if value.blank?
    Time.parse(value).in_time_zone(BVI_TIMEZONE)
  rescue ArgumentError
    nil
  end

  def user_agent
    "Mozilla/5.0 (compatible; BVICruiseTracker/1.0)"
  end
end
