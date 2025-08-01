class AddDurationToTrips < ActiveRecord::Migration[7.1]
  def change
    add_column :trips, :duration, :integer
  end
end
