class ScraperMonitorService
  def self.log_success(source:, records_fetched:)
    ScrapeLog.create!(
      source: source,
      status: "success",
      records_fetched: records_fetched,
      scraped_at: Time.current
    )
  end

  def self.log_warning(source:, message:, records_fetched: 0)
    ScrapeLog.create!(
      source: source,
      status: "warning",
      records_fetched: records_fetched,
      error_message: message,
      scraped_at: Time.current
    )
    send_alert("⚠️ Scraper Warning [#{source}]: #{message}")
  end

  def self.log_error(source:, message:)
    ScrapeLog.create!(
      source: source,
      status: "error",
      records_fetched: 0,
      error_message: message,
      scraped_at: Time.current
    )
    send_alert("🚨 Scraper Error [#{source}]: #{message}")
  end

  def self.check_data_freshness
    %w[crew_center cruisedig].each do |source|
      last_success = ScrapeLog.last_successful_for(source)

      if last_success.nil?
        send_alert("⚠️ No successful scrape ever recorded for #{source}")
        next
      end

      hours_since = ((Time.current - last_success.scraped_at) / 1.hour).round
      if hours_since > 48
        send_alert("⚠️ Stale data [#{source}]: Last successful scrape was #{hours_since} hours ago")
      end
    end
  end

  def self.send_alert(message)
    webhook_url = AppConfig.get("slack_webhook_url")

    if webhook_url.present?
      begin
        HTTParty.post(webhook_url, body: { text: message }.to_json, headers: { "Content-Type" => "application/json" }, timeout: 10)
      rescue => e
        Rails.logger.error("Failed to send Slack alert: #{e.message}")
      end
    end

    Rails.logger.warn(message)
  end
end
