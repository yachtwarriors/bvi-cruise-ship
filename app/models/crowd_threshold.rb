class CrowdThreshold < ApplicationRecord
  belongs_to :location

  validates :green_max, presence: true, numericality: { greater_than: 0 }
  validates :yellow_max, presence: true, numericality: { greater_than: 0 }
  validates :location_id, uniqueness: true

  def intensity_for(visitor_count)
    if visitor_count <= green_max
      "green"
    elsif visitor_count <= yellow_max
      "yellow"
    else
      "red"
    end
  end
end
