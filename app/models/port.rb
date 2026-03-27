class Port < ApplicationRecord
  has_many :cruise_visits, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  ROAD_TOWN = "road-town".freeze
  SPANISH_TOWN = "spanish-town".freeze
  JOST_VAN_DYKE = "jost-van-dyke".freeze
  NORMAN_ISLAND = "norman-island".freeze
  GORDA_SOUND = "gorda-sound".freeze

  scope :by_slug, ->(slug) { find_by!(slug: slug) }
end
