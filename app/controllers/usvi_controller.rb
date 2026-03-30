class UsviController < ApplicationController
  TIMEZONE = "America/Virgin".freeze

  def show
    @today = Time.use_zone(TIMEZONE) { Time.zone.today }
    @start_date = parse_start_date(@today)
    @end_date = @start_date + 6.days

    @dates = (@start_date..@end_date).to_a
    @prev_week_start = @start_date - 7.days
    @next_week_start = @start_date + 7.days

    # St. Thomas section
    @st_thomas_port = Port.find_by!(slug: Port::CHARLOTTE_AMALIE)
    @st_thomas_locations = Location.usvi.where(port: @st_thomas_port).includes(:crowd_threshold)

    # St. Croix section
    @st_croix_port = Port.find_by!(slug: Port::FREDERIKSTED)
    @st_croix_locations = Location.usvi.where(port: @st_croix_port).includes(:crowd_threshold)

    # All USVI visits grouped by date
    usvi_port_ids = [@st_thomas_port.id, @st_croix_port.id]
    all_visits = CruiseVisit.includes(:port)
      .where(port_id: usvi_port_ids)
      .in_range(@start_date, @end_date)

    @st_thomas_visits_by_date = all_visits.select { |v| v.port_id == @st_thomas_port.id }.group_by(&:visit_date)
    @st_croix_visits_by_date = all_visits.select { |v| v.port_id == @st_croix_port.id }.group_by(&:visit_date)

    # Snapshots for all USVI locations
    usvi_location_ids = (@st_thomas_locations + @st_croix_locations).map(&:id)
    @snapshots = CrowdSnapshot.includes(:location)
      .where(location_id: usvi_location_ids)
      .in_range(@start_date, @end_date)
      .daytime.ordered
      .group_by { |s| [s.snapshot_date, s.location_id] }
  end
end
