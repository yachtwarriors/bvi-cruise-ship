class AddUsviSupport < ActiveRecord::Migration[8.0]
  def change
    add_column :ports, :territory, :string, null: false, default: "bvi"
    add_column :locations, :territory, :string, null: false, default: "bvi"
    add_reference :locations, :port, null: true, foreign_key: true

    add_index :ports, :territory
    add_index :locations, :territory
  end
end
