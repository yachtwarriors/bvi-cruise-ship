class ScraperOrchestratorService
  BVI_TIMEZONE = "America/Virgin".freeze

  def self.run
    new.run
  end

  def run
    today = Time.use_zone(BVI_TIMEZONE) { Time.zone.today }
    total_records = 0
    @pruned_dates = []

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
      prune_cancelled(source_name, visits)
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

  # A sailing that vanishes from the source has been cancelled or rescheduled, so
  # it must not keep driving a crowd forecast. Only future dates are touched —
  # past visits are the historical record.
  #
  # Guarded on coverage: a partial or degraded scrape must never be able to empty
  # the schedule. If this run returned substantially less than we already hold,
  # we keep what we have and log it rather than deleting.
  MIN_COVERAGE_RATIO = 0.5

  # Evaluated per port, not across the whole source. A single port failing or
  # returning an empty page would otherwise have all of its sailings deleted
  # while the source-wide total still cleared the coverage check.
  def prune_cancelled(source_name, visits)
    today = Time.use_zone(BVI_TIMEZONE) { Time.zone.today }
    by_port = visits.group_by { |a| a[:port_id] }

    by_port.each do |port_id, port_visits|
      existing = CruiseVisit.where(source: source_name, port_id: port_id).where("visit_date >= ?", today)
      existing_count = existing.count
      next if existing_count.zero?

      if port_visits.size < existing_count * MIN_COVERAGE_RATIO
        ScraperMonitorService.log_warning(
          source: source_name,
          message: "Skipped pruning port #{port_id}: #{port_visits.size} scraped against #{existing_count} on file",
          records_fetched: port_visits.size
        )
        next
      end

      scraped = port_visits.map { |a| [a[:ship_name], a[:visit_date]] }.to_set
      stale = existing.reject { |v| scraped.include?([v.ship_name, v.visit_date]) }
      next if stale.empty?

      @pruned_dates.concat(stale.map(&:visit_date))
      stale.each { |v| Rails.logger.info("Pruning cancelled sailing: #{v.ship_name} at port #{port_id} on #{v.visit_date}") }
      CruiseVisit.where(id: stale.map(&:id)).delete_all
      Rails.logger.info("Pruned #{stale.size} cancelled #{source_name} sailings at port #{port_id}")
    end
  end

  def recalculate_crowds(today)
    # Only recalculate today and future — past crowd snapshots are frozen
    dates = CruiseVisit.where("visit_date >= ?", today).distinct.pluck(:visit_date)
    # Dates whose last ship was just pruned still hold stale snapshots and would
    # otherwise never be revisited, since no visit remains to pick them up.
    dates = (dates + @pruned_dates.to_a).uniq.select { |d| d >= today }.sort
    return if dates.empty?

    CrowdCalculationService.calculate_for_dates(dates)
  end
end
