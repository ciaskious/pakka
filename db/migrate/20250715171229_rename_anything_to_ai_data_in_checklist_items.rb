class RenameAnythingToAiDataInChecklistItems < ActiveRecord::Migration[7.1]
  def change
    rename_column :checklist_items, :anything, :ai_data
  end
end
