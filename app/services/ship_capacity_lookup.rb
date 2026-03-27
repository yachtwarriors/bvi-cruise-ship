class ShipCapacityLookup
  CAPACITIES = YAML.load_file(Rails.root.join("db/seeds/ship_capacities.yml")).freeze

  def self.find(ship_name)
    # Try exact match first
    return CAPACITIES[ship_name] if CAPACITIES.key?(ship_name)

    # Try case-insensitive match
    CAPACITIES.each do |name, capacity|
      return capacity if name.downcase == ship_name.downcase
    end

    # Try partial match (e.g., "Norwegian Epic" matches "Norwegian Epic")
    CAPACITIES.each do |name, capacity|
      return capacity if ship_name.downcase.include?(name.downcase) || name.downcase.include?(ship_name.downcase)
    end

    nil
  end

  def self.median_capacity
    values = CAPACITIES.values.sort
    mid = values.length / 2
    values.length.odd? ? values[mid] : (values[mid - 1] + values[mid]) / 2
  end
end
