class CreateCrowdSnapshots < ActiveRecord::Migration[8.0]
  def change
    create_table :crowd_snapshots do |t|
      t.references :location, null: false, foreign_key: true
      t.date :snapshot_date, null: false
      t.integer :hour, null: false
      t.string :intensity, null: false
      t.integer :estimated_visitors, default: 0
      t.jsonb :contributing_ships, default: []

      t.timestamps
    end
    add_index :crowd_snapshots, [:location_id, :snapshot_date, :hour], unique: true, name: "idx_crowd_snapshots_unique"
    add_index :crowd_snapshots, :snapshot_date
  end
end
