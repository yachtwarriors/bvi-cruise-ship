class Rack::Attack
  # Throttle all requests by IP (60 requests per minute)
  throttle("req/ip", limit: 60, period: 1.minute) do |req|
    req.ip unless req.path.start_with?("/assets", "/packs")
  end

  # Stricter throttle on pages with start_date param (10 per minute)
  # Bots probe this param with thousands of garbage dates
  throttle("start_date_probe/ip", limit: 10, period: 1.minute) do |req|
    req.ip if req.params["start_date"].present?
  end

  # Block known bad IPs (the bots from the logs)
  blocklist("block bad IPs") do |req|
    %w[74.7.243.205 74.7.242.0].include?(req.ip)
  end

  # Return 429 with a short body
  self.throttled_responder = lambda do |_env|
    [429, { "Content-Type" => "text/plain" }, ["Rate limited. Try again later.\n"]]
  end
end
