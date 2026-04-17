class SitemapController < ApplicationController
  def index
    last_scrape = ScrapeLog.where(status: "success").order(scraped_at: :desc).first

    lastmod = last_scrape&.scraped_at&.iso8601 || Time.current.iso8601

    @urls = [
      { url: root_url, lastmod: lastmod, changefreq: "daily", priority: "1.0" },
      { url: usvi_url, lastmod: lastmod, changefreq: "daily", priority: "0.9" },
      # Port pages
      { url: tortola_url, lastmod: lastmod, changefreq: "daily", priority: "0.8" },
      { url: virgin_gorda_url, lastmod: lastmod, changefreq: "daily", priority: "0.8" },
      { url: st_thomas_url, lastmod: lastmod, changefreq: "daily", priority: "0.8" },
      { url: st_croix_url, lastmod: lastmod, changefreq: "daily", priority: "0.8" },
      # Beach/attraction pages
      { url: the_baths_url, lastmod: lastmod, changefreq: "daily", priority: "0.7" },
      { url: cane_garden_bay_url, lastmod: lastmod, changefreq: "daily", priority: "0.7" },
      { url: white_bay_url, lastmod: lastmod, changefreq: "daily", priority: "0.7" },
      { url: magens_bay_url, lastmod: lastmod, changefreq: "daily", priority: "0.7" },
      { url: coki_beach_url, lastmod: lastmod, changefreq: "daily", priority: "0.7" },
      { url: national_park_beaches_url, lastmod: lastmod, changefreq: "daily", priority: "0.7" },
      { url: rainbow_beach_url, lastmod: lastmod, changefreq: "daily", priority: "0.7" },
      { url: buck_island_url, lastmod: lastmod, changefreq: "daily", priority: "0.7" },
    ]

    respond_to do |format|
      format.xml
    end
  end
end
