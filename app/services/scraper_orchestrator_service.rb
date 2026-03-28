class ScraperOrchestratorService
  BVI_TIMEZONE = "America/Virgin".freeze

  def self.run
    new.run
  end

  def run
    today = Time.use_zone(BVI_TIMEZONE) { Time.zone.today }
    total_records = 0

    # 1. Scrape Crew Center (near-term, high-quality data)
    total_records += scrape_source("crew_center") { CrewCenterScraperService.fetch_all }

    # 2. Scrape CruiseDig (extended date range)
    total_records += scrape_source("cruisedig") { CruiseDigScraperService.fetch_all }

    # 3. Recalculate crowd intensities for today and future dates only
    #    Past dates are preserved as historical record
    recalculate_crowds(today)

    # 4. Check data freshness
    ScraperMonitorService.check_data_freshness

    Rails.logger.info("Scraper complete: #{total_records} total records processed")
  end

  private

  def scrape_source(source_name)
    visits = yield
    persisted = persist_visits(visits)

    if visits.empty?
      ScraperMonitorService.log_warning(source: source_name, message: "Zero records returned")
    else
      ScraperMonitorService.log_success(source: source_name, records_fetched: persisted)
    end

    persisted
  rescue => e
    ScraperMonitorService.log_error(source: source_name, message: "#{e.class}: #{e.message}")
    0
  end

  def persist_visits(visits)
    today = Time.use_zone(BVI_TIMEZONE) { Time.zone.today }
    count = 0

    ActiveRecord::Base.transaction do
      visits.each do |attrs|
        visit = CruiseVisit.find_or_initialize_by(
          ship_name: attrs[:ship_name],
          visit_date: attrs[:visit_date],
          port_id: attrs[:port_id]
        )

        # Future/today dates: always update with latest scraped data (schedules change)
        # Past dates: only create if new, never overwrite historical records
        if visit.new_record?
          visit.assign_attributes(attrs)
          visit.save!
          count += 1
        elsif attrs[:visit_date] >= today
          # Future date — refresh with latest data
          # Prefer crew_center data over cruisedig
          if attrs[:source] == "crew_center" || visit.source != "crew_center"
            visit.assign_attributes(attrs)
            if visit.changed?
              visit.save!
              count += 1
            end
          end
        end
        # Past dates with existing records: skip (preserve historical data)
      end
    end

    count
  end

  def recalculate_crowds(today)
    # Only recalculate today and future — past crowd snapshots are frozen
    dates = CruiseVisit.where("visit_date >= ?", today).distinct.pluck(:visit_date).sort
    return if dates.empty?

    CrowdCalculationService.calculate_for_dates(dates)
  end
end
