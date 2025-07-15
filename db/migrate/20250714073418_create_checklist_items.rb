class CreateChecklistItems < ActiveRecord::Migration[7.1]
  def change
    create_table :checklist_items do |t|
      t.references :trip, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.string :name
      t.boolean :checked
      t.jsonb :anything

      t.timestamps
    end
  end
end
