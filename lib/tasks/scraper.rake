namespace :scraper do
  desc "Fetch cruise ship schedules and recalculate crowd intensities"
  task fetch_schedules: :environment do
    puts "[#{Time.current}] Starting cruise ship schedule scrape..."
    ScraperOrchestratorService.run
    puts "[#{Time.current}] Scrape complete."
  end
end
