class SetChecklistItemCheckedDefault < ActiveRecord::Migration[7.1]
  def change
    change_column_default :checklist_items, :checked, from: nil, to: false
    change_column_null :checklist_items, :checked, false
  end
end
