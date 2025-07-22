class MakeChecklistItemItemIdNullable < ActiveRecord::Migration[7.1]
  def change
    change_column_null :checklist_items, :item_id, true
  end
end
