class CreateItems < ActiveRecord::Migration[7.1]
  def change
    create_table :items do |t|
      t.string :name
      t.string :category
      t.boolean :default

      t.timestamps
    end
  end
end
