class CreateScrapeLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :scrape_logs do |t|
      t.string :source
      t.string :status
      t.integer :records_fetched
      t.text :error_message
      t.datetime :scraped_at

      t.timestamps
    end
  end
end
