class SitemapController < ApplicationController
  def index
    last_scrape = ScrapeLog.where(status: "success").order(scraped_at: :desc).first

    @urls = [
      {
        url: root_url,
        lastmod: last_scrape&.scraped_at&.iso8601 || Time.current.iso8601,
        changefreq: "daily",
        priority: "1.0"
      }
    ]

    respond_to do |format|
      format.xml
    end
  end
end
