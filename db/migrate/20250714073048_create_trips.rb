class CreateTrips < ActiveRecord::Migration[7.1]
  def change
    create_table :trips do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.string :destination
      t.string :country
      t.float :latitude
      t.float :longitude
      t.date :start_date
      t.date :end_date
      t.boolean :public
      t.jsonb :weather_data
      t.jsonb :accommodation_data

      t.timestamps
    end
  end
end
