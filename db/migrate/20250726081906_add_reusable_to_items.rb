class AddReusableToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :reusable, :boolean, default: false, null: false
  end
end
