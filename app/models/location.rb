class Location < ApplicationRecord
  has_many :crowd_snapshots, dependent: :destroy
  has_one :crowd_threshold, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  THE_BATHS = "the-baths".freeze
  WHITE_BAY = "white-bay".freeze

  scope :by_slug, ->(slug) { find_by!(slug: slug) }
end
