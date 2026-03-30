class PagesController < ApplicationController
  BVI_TIMEZONE = "America/Virgin".freeze

  def home
    @today = Time.use_zone(BVI_TIMEZONE) { Time.zone.today }
    @start_date = begin
      params[:start_date]&.to_date || @today
    rescue Date::Error
      @today
    end
    @end_date = @start_date + 6.days

    @dates = (@start_date..@end_date).to_a
    @prev_week_start = @start_date - 7.days
    @next_week_start = @start_date + 7.days

    # Load BVI cruise visits only
    bvi_port_ids = Port.bvi.pluck(:id)
    @visits_by_date = CruiseVisit.includes(:port)
      .where(port_id: bvi_port_ids)
      .in_range(@start_date, @end_date)
      .group_by(&:visit_date)

    # Load BVI locations and snapshots only
    @locations = Location.bvi.includes(:crowd_threshold)
    bvi_location_ids = @locations.map(&:id)
    @snapshots = CrowdSnapshot.includes(:location)
      .where(location_id: bvi_location_ids)
      .in_range(@start_date, @end_date)
      .daytime
      .ordered
      .group_by { |s| [s.snapshot_date, s.location_id] }

    # Rolling stats for comparison bar
    @cruise_stats = build_cruise_stats
  end

  private

  def build_cruise_stats
    Rails.cache.fetch("cruise_stats/#{@today}", expires_in: 1.hour) do
      last_7_start = @today - 6.days
      last_30_start = @today - 29.days
      last_year_7_start = last_7_start - 1.year
      last_year_7_end = @today - 1.year
      last_year_30_start = last_30_start - 1.year
      last_year_30_end = @today - 1.year

      stats = {}

      stats[:last_7] = window_stats(last_7_start, @today)
      stats[:last_7_ly] = window_stats(last_year_7_start, last_year_7_end)
      stats[:last_30] = window_stats(last_30_start, @today)
      stats[:last_30_ly] = window_stats(last_year_30_start, last_year_30_end)

      stats
    end
  end

  def window_stats(start_date, end_date)
    visits = CruiseVisit.joins(:port).where(port: { territory: "bvi" }).where(visit_date: start_date..end_date)
    {
      ships: visits.count,
      guests: visits.sum(:passenger_capacity)
    }
  end
end
