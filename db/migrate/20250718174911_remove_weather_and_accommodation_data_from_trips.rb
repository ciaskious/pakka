class RemoveWeatherAndAccommodationDataFromTrips < ActiveRecord::Migration[7.1]
  def change
    remove_column :trips, :weather_data, :jsonb
    remove_column :trips, :accommodation_data, :jsonb
  end
end
