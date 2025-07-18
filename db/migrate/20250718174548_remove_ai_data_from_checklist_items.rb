class RemoveAiDataFromChecklistItems < ActiveRecord::Migration[7.1]
  def change
    remove_column :checklist_items, :ai_data, :jsonb
  end
end
