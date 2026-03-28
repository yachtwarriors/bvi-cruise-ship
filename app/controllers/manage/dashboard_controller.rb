module Manage
  class DashboardController < BaseController
    def index
      @locations = Location.includes(:crowd_threshold).all
      @recent_logs = ScrapeLog.recent.limit(10)
      @configs = AppConfig.order(:key)
      @visit_count = CruiseVisit.count
      @snapshot_count = CrowdSnapshot.count
    end

    def recalculate
      today = Time.use_zone("America/Virgin") { Time.zone.today }
      dates = CruiseVisit.where("visit_date >= ?", today).distinct.pluck(:visit_date).sort
      CrowdCalculationService.calculate_for_dates(dates)
      redirect_to manage_root_path, notice: "Recalculated crowd data for #{dates.size} dates."
    end
  end
end
