class RemoveDescriptionFromTrips < ActiveRecord::Migration[7.1]
  def change
    remove_column :trips, :description, :text
  end
end
