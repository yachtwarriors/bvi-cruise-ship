class CreateCruiseVisits < ActiveRecord::Migration[8.0]
  def change
    create_table :cruise_visits do |t|
      t.references :port, null: false, foreign_key: true
      t.string :ship_name, null: false
      t.string :cruise_line
      t.integer :passenger_capacity
      t.datetime :arrival_at
      t.datetime :departure_at
      t.date :visit_date, null: false
      t.string :source
      t.boolean :capacity_estimated, default: false

      t.timestamps
    end
    add_index :cruise_visits, [:ship_name, :visit_date, :port_id], unique: true, name: "idx_cruise_visits_unique"
    add_index :cruise_visits, :visit_date
  end
end
