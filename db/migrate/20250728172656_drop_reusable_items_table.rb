class DropReusableItemsTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :reusable_items
  end
end
