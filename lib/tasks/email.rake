namespace :email do
  desc "Send daily crowd alert emails to users with active alert windows"
  task send_daily_alerts: :environment do
    date = Time.use_zone("America/Virgin") { Time.zone.today }

    puts "[#{Time.current}] Sending daily crowd alerts for #{date}..."

    unless ENV["DAILY_EMAIL_ENABLED"] == "true"
      puts "[#{Time.current}] Daily emails disabled (DAILY_EMAIL_ENABLED != 'true'). Skipping."
      next
    end

    users = User.with_active_alerts_for(date).email_enabled

    if ENV["MATT_ONLY_EMAILS"] == "true"
      matt_email = ENV.fetch("MATT_EMAIL", "matt@yachtwarriors.com")
      users = users.where(email: matt_email)
    end

    puts "[#{Time.current}] Found #{users.count} user(s) to email."

    users.find_each do |user|
      DailyCrowdAlertMailer.daily_alert(user, date).deliver_now
      puts "[#{Time.current}] Sent alert to #{user.email}"
    rescue => e
      puts "[#{Time.current}] ERROR sending to #{user.email}: #{e.message}"
      ScraperMonitorService.send_alert("🚨 Email send failed for #{user.email}: #{e.message}")
    end

    puts "[#{Time.current}] Daily alerts complete."
  rescue => e
    ScraperMonitorService.send_alert("🚨 Daily email task failed: #{e.class}: #{e.message}")
    raise
  end
end
