class CruiseVisit < ApplicationRecord
  belongs_to :port

  validates :ship_name, presence: true
  validates :visit_date, presence: true
  validates :ship_name, uniqueness: { scope: [:visit_date, :port_id] }

  scope :on_date, ->(date) { where(visit_date: date) }
  scope :in_range, ->(start_date, end_date) { where(visit_date: start_date..end_date) }
  scope :at_port, ->(port) { where(port: port) }
end
