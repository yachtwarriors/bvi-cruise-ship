class CrowdSnapshot < ApplicationRecord
  belongs_to :location

  validates :snapshot_date, presence: true
  validates :hour, presence: true, inclusion: { in: 0..23 }
  validates :intensity, presence: true, inclusion: { in: %w[green yellow red] }
  validates :hour, uniqueness: { scope: [:location_id, :snapshot_date] }

  scope :on_date, ->(date) { where(snapshot_date: date) }
  scope :in_range, ->(start_date, end_date) { where(snapshot_date: start_date..end_date) }
  scope :for_location, ->(location) { where(location: location) }
  scope :daytime, -> { where(hour: 6..20) }
  scope :ordered, -> { order(:snapshot_date, :hour) }
end
