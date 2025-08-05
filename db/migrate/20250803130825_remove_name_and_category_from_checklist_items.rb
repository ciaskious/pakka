class RemoveNameAndCategoryFromChecklistItems < ActiveRecord::Migration[7.1]
  def change
    remove_column :checklist_items, :name, :string
    remove_column :checklist_items, :category, :string
  end
end
