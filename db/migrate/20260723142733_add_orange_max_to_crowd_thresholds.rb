class AddOrangeMaxToCrowdThresholds < ActiveRecord::Migration[8.0]
  # Splits the old yellow band into yellow and orange. The red line is left
  # exactly where it was, so nothing that warns today stops warning -- we only
  # gain resolution below it. Under three levels a beach could sit at 573 people
  # against a 600 red line and look identical to one at 258.
  def up
    add_column :crowd_thresholds, :orange_max, :integer

    execute <<~SQL
      UPDATE crowd_thresholds
      SET orange_max = yellow_max,
          yellow_max = (green_max + yellow_max) / 2
    SQL

    change_column_null :crowd_thresholds, :orange_max, false
  end

  def down
    execute <<~SQL
      UPDATE crowd_thresholds
      SET yellow_max = orange_max
    SQL

    remove_column :crowd_thresholds, :orange_max
  end
end
