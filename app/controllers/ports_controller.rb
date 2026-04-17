class PortsController < ApplicationController
  TIMEZONE = "America/Virgin".freeze

  # Maps port slugs to the location slugs whose crowds they contribute to.
  # This is NOT just port.locations — some locations are reachable from ports
  # they don't belong_to (e.g., The Baths via Road Town ferry excursion).
  PORT_LOCATION_MAP = {
    Port::ROAD_TOWN => [Location::THE_BATHS, Location::WHITE_BAY, Location::CANE_GARDEN_BAY],
    Port::SPANISH_TOWN => [Location::THE_BATHS],
    Port::GORDA_SOUND => [Location::THE_BATHS],
    Port::CHARLOTTE_AMALIE => [Location::MAGENS_BAY, Location::COKI_BEACH, Location::NATIONAL_PARK_BEACHES],
    Port::FREDERIKSTED => [Location::RAINBOW_BEACH, Location::BUCK_ISLAND],
  }.freeze

  # Virgin Gorda aggregates two ports into one page
  VIRGIN_GORDA_PORTS = [Port::SPANISH_TOWN, Port::GORDA_SOUND].freeze

  def show
    @today = Time.use_zone(TIMEZONE) { Time.zone.today }
    @start_date = parse_start_date(@today)
    @end_date = @start_date + 6.days
    @dates = (@start_date..@end_date).to_a
    @prev_week_start = @start_date - 7.days
    @next_week_start = @start_date + 7.days

    @port_slug = params[:slug]

    if @port_slug == "virgin-gorda"
      load_virgin_gorda
    else
      load_single_port
    end
  end

  private

  def load_single_port
    @port = Port.find_by!(slug: @port_slug)
    @ports = [@port]

    location_slugs = PORT_LOCATION_MAP[@port_slug] || []
    @locations = Location.where(slug: location_slugs).includes(:crowd_threshold)

    @visits_by_date = CruiseVisit.includes(:port)
      .where(port: @port)
      .in_range(@start_date, @end_date)
      .group_by(&:visit_date)

    load_snapshots
  end

  def load_virgin_gorda
    @ports = Port.where(slug: VIRGIN_GORDA_PORTS)
    @port = @ports.find { |p| p.slug == Port::SPANISH_TOWN }

    location_slugs = VIRGIN_GORDA_PORTS.flat_map { |slug| PORT_LOCATION_MAP[slug] || [] }.uniq
    @locations = Location.where(slug: location_slugs).includes(:crowd_threshold)

    @visits_by_date = CruiseVisit.includes(:port)
      .where(port_id: @ports.map(&:id))
      .in_range(@start_date, @end_date)
      .group_by(&:visit_date)

    load_snapshots
  end

  def load_snapshots
    @snapshots = CrowdSnapshot.includes(:location)
      .where(location_id: @locations.map(&:id))
      .in_range(@start_date, @end_date)
      .daytime.ordered
      .group_by { |s| [s.snapshot_date, s.location_id] }
  end
end
