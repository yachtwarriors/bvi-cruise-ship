class CreateCrowdThresholds < ActiveRecord::Migration[8.0]
  def change
    create_table :crowd_thresholds do |t|
      t.references :location, null: false, foreign_key: true, index: { unique: true }
      t.integer :green_max, null: false
      t.integer :yellow_max, null: false

      t.timestamps
    end
  end
end
