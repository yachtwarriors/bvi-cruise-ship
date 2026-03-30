class Location < ApplicationRecord
  belongs_to :port, optional: true
  has_many :crowd_snapshots, dependent: :destroy
  has_one :crowd_threshold, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  # BVI
  THE_BATHS = "the-baths".freeze
  WHITE_BAY = "white-bay".freeze
  CANE_GARDEN_BAY = "cane-garden-bay".freeze

  # USVI
  MAGENS_BAY = "magens-bay".freeze
  COKI_BEACH = "coki-beach".freeze
  NATIONAL_PARK_BEACHES = "national-park-beaches".freeze
  RAINBOW_BEACH = "rainbow-beach".freeze
  BUCK_ISLAND = "buck-island".freeze

  scope :by_slug, ->(slug) { find_by!(slug: slug) }
  scope :bvi, -> { where(territory: "bvi") }
  scope :usvi, -> { where(territory: "usvi") }
end
