class AddAccommodationTypeToTrips < ActiveRecord::Migration[7.1]
  def change
    add_column :trips, :accommodation_type, :string
  end
end
