class CrowdThreshold < ApplicationRecord
  belongs_to :location

  validates :green_max, presence: true, numericality: { greater_than: 0 }
  validates :yellow_max, presence: true, numericality: { greater_than: 0 }
  validates :orange_max, presence: true, numericality: { greater_than: 0 }
  validates :location_id, uniqueness: true
  validate :bands_must_ascend

  def intensity_for(visitor_count)
    if visitor_count <= green_max
      "green"
    elsif visitor_count <= yellow_max
      "yellow"
    elsif visitor_count <= orange_max
      "orange"
    else
      "red"
    end
  end

  private

  # Overlapping bands would silently make a level unreachable.
  def bands_must_ascend
    return if [ green_max, yellow_max, orange_max ].any?(&:blank?)

    errors.add(:yellow_max, "must be above the green threshold") if yellow_max <= green_max
    errors.add(:orange_max, "must be above the yellow threshold") if orange_max <= yellow_max
  end
end
