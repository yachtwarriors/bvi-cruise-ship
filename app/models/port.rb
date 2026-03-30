class Port < ApplicationRecord
  has_many :cruise_visits, dependent: :destroy
  has_many :locations

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  # BVI
  ROAD_TOWN = "road-town".freeze
  SPANISH_TOWN = "spanish-town".freeze
  JOST_VAN_DYKE = "jost-van-dyke".freeze
  NORMAN_ISLAND = "norman-island".freeze
  GORDA_SOUND = "gorda-sound".freeze

  # USVI
  CHARLOTTE_AMALIE = "charlotte-amalie".freeze
  FREDERIKSTED = "frederiksted".freeze

  scope :by_slug, ->(slug) { find_by!(slug: slug) }
  scope :bvi, -> { where(territory: "bvi") }
  scope :usvi, -> { where(territory: "usvi") }
end
