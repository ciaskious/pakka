class ModifyItemsTable < ActiveRecord::Migration[7.1]
  def change
    # Renommer la colonne category en description
    rename_column :items, :category, :description

    # Supprimer la colonne default
    remove_column :items, :default, :boolean

    # Ajouter une colonne user_id
    add_reference :items, :user, null: false, foreign_key: true
  end
end
