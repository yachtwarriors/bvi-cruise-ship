class PagesController < ApplicationController
  BVI_TIMEZONE = "America/Virgin".freeze

  def home
    @today = Time.use_zone(BVI_TIMEZONE) { Time.zone.today }
    @start_date = params[:start_date]&.to_date || @today
    @end_date = @start_date + 6.days

    @dates = (@start_date..@end_date).to_a
    @prev_week_start = @start_date - 7.days
    @next_week_start = @start_date + 7.days

    # Load all cruise visits for the date range
    @visits_by_date = CruiseVisit.includes(:port)
      .in_range(@start_date, @end_date)
      .group_by(&:visit_date)

    # Load crowd snapshots for both locations
    @locations = Location.includes(:crowd_threshold).all
    @snapshots = CrowdSnapshot.includes(:location)
      .in_range(@start_date, @end_date)
      .daytime
      .ordered
      .group_by { |s| [s.snapshot_date, s.location_id] }
  end
end
