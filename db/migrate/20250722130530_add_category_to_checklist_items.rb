class AddCategoryToChecklistItems < ActiveRecord::Migration[7.1]
  def change
    add_column :checklist_items, :category, :string
  end
end
