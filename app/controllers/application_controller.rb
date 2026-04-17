class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_last_scrape_at

  private

  def set_last_scrape_at
    @last_scrape_at = Rails.cache.fetch("last_scrape_at", expires_in: 10.minutes) do
      ScrapeLog.last_successful&.scraped_at || Time.current
    end
  end

  # Clamp start_date to a sane range — rejects bot probing with dates like 6428-11-10
  def parse_start_date(today)
    date = params[:start_date]&.to_date || today
    min_date = today - 2.years
    max_date = today + 2.years
    date.clamp(min_date, max_date)
  rescue Date::Error
    today
  end

  def require_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "Not authorized."
    end
  end

  def after_sign_in_path_for(resource)
    if resource.is_a?(User) && resource.admin?
      manage_root_path
    else
      root_path
    end
  end
end
