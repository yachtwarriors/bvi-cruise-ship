class CreatePorts < ActiveRecord::Migration[8.0]
  def change
    create_table :ports do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6

      t.timestamps
    end
    add_index :ports, :slug, unique: true
  end
end
