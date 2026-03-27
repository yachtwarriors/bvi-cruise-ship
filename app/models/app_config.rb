class AppConfig < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :value, presence: true

  def self.get(key, default: nil)
    find_by(key: key)&.value || default
  end

  def self.get_float(key, default: 0.0)
    get(key, default: default.to_s).to_f
  end

  def self.get_int(key, default: 0)
    get(key, default: default.to_s).to_i
  end

  def self.set(key, value, description: nil)
    record = find_or_initialize_by(key: key)
    record.value = value.to_s
    record.description = description if description
    record.save!
  end
end
