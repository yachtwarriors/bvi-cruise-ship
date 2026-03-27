class ScraperOrchestratorService
  def self.run
    new.run
  end

  def run
    total_records = 0

    # 1. Scrape Crew Center (near-term, high-quality data)
    total_records += scrape_source("crew_center") { CrewCenterScraperService.fetch_all }

    # 2. Scrape CruiseDig (extended date range)
    total_records += scrape_source("cruisedig") { CruiseDigScraperService.fetch_all }

    # 3. Recalculate crowd intensities for all dates with new/updated visits
    recalculate_crowds

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
    count = 0

    visits.each do |attrs|
      visit = CruiseVisit.find_or_initialize_by(
        ship_name: attrs[:ship_name],
        visit_date: attrs[:visit_date],
        port_id: attrs[:port_id]
      )

      # Update with latest data (Crew Center may have better data than CruiseDig)
      # Prefer crew_center data over cruisedig if both exist
      if visit.new_record? || attrs[:source] == "crew_center"
        visit.assign_attributes(attrs)
        visit.save! if visit.changed?
        count += 1 if visit.previously_new_record? || visit.saved_changes.any?
      end
    end

    count
  end

  def recalculate_crowds
    # Recalculate for dates that have cruise visits
    dates = CruiseVisit.distinct.pluck(:visit_date).sort
    return if dates.empty?

    CrowdCalculationService.calculate_for_dates(dates)
  end
end
