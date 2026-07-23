class AddExpectedPassengersToCruiseVisits < ActiveRecord::Migration[8.0]
  def change
    add_column :cruise_visits, :expected_passengers, :integer
  end
end
