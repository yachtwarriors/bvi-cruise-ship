class ScrapeLog < ApplicationRecord
  validates :source, presence: true
  validates :status, presence: true, inclusion: { in: %w[success warning error] }

  scope :recent, -> { order(scraped_at: :desc) }
  scope :failures, -> { where(status: %w[warning error]) }

  def self.last_successful
    where(status: "success").recent.first
  end

  def self.last_successful_for(source)
    where(status: "success", source: source).recent.first
  end
end
