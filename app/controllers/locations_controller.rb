class LocationsController < ApplicationController
  include PagesHelper

  TIMEZONE = "America/Virgin".freeze

  def show
    @today = Time.use_zone(TIMEZONE) { Time.zone.today }
    @start_date = parse_start_date(@today)
    @end_date = @start_date + 6.days
    @dates = (@start_date..@end_date).to_a
    @prev_week_start = @start_date - 7.days
    @next_week_start = @start_date + 7.days

    @location = Location.includes(:crowd_threshold).find_by!(slug: params[:slug])

    # Find contributing ports for this location
    port_slugs = contributing_port_slugs_for(@location.slug)
    @contributing_ports = Port.where(slug: port_slugs)

    # Load visits from contributing ports
    @visits_by_date = CruiseVisit.includes(:port)
      .where(port_id: @contributing_ports.map(&:id))
      .in_range(@start_date, @end_date)
      .group_by(&:visit_date)

    # Load snapshots for this single location
    @snapshots_by_date = CrowdSnapshot
      .where(location: @location)
      .in_range(@start_date, @end_date)
      .daytime.ordered
      .group_by(&:snapshot_date)

    # Today's data for the hero
    @today_snapshots = @snapshots_by_date[@today] || []
    @today_visits = @visits_by_date[@today] || []
    @today_peak = peak_intensity_for(@today_snapshots)
    @today_passengers = total_passengers_for(@today_visits)
    @best_time = compute_best_time(@today_snapshots)
  end

  private

  def compute_best_time(snapshots)
    return nil if snapshots.blank?

    by_hour = snapshots.index_by(&:hour)
    hours = (7..17).to_a

    # Find first window of 2+ consecutive green hours
    window = find_consecutive_window(hours, by_hour, "green", 2)
    return format_time_window(window) if window

    # Fall back to yellow windows
    window = find_consecutive_window(hours, by_hour, "yellow", 2)
    return format_time_window(window) if window

    # All red — recommend early or late
    "early morning (before 10am) or late afternoon (after 3pm)"
  end

  def find_consecutive_window(hours, by_hour, target_intensity, min_length)
    current_run = []
    hours.each do |hour|
      intensity = by_hour[hour]&.intensity || "green"
      if intensity == target_intensity || (target_intensity == "yellow" && intensity == "green")
        current_run << hour
      else
        return current_run if current_run.length >= min_length
        current_run = []
      end
    end
    current_run.length >= min_length ? current_run : nil
  end

  def format_time_window(hours)
    start_hour = hours.first
    end_hour = hours.last + 1
    "#{format_hour(start_hour)} – #{format_hour(end_hour)}"
  end
end
