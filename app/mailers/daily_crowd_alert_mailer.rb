class DailyCrowdAlertMailer < ApplicationMailer
  helper PagesHelper

  def daily_alert(user, date)
    @user = user
    @date = date
    @visits = CruiseVisit.includes(:port).on_date(date).order(:visit_date)
    @locations = Location.includes(:crowd_threshold).all
    @snapshots = CrowdSnapshot.includes(:location)
                              .on_date(date).daytime.ordered
                              .group_by(&:location_id)
    @total_passengers = @visits.sum { |v| v.passenger_capacity || 0 }
    @day_peak = compute_day_peak

    mail(
      to: user.email,
      subject: "BVI Crowd Report — #{date.strftime('%A, %B %-d')}"
    )
  end

  private

  def compute_day_peak
    priorities = { "red" => 3, "yellow" => 2, "green" => 1 }
    @locations.map { |loc|
      snapshots = @snapshots[loc.id] || []
      return "green" if snapshots.blank?
      snapshots.max_by { |s| priorities[s.intensity] || 0 }&.intensity || "green"
    }.max_by { |i| priorities[i] || 0 }
  end
end
