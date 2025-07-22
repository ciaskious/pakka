class RenameDescriptionToCategoryInItems < ActiveRecord::Migration[7.1]
  def change
    rename_column :items, :description, :category
  end
end
