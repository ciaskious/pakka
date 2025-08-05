class MakeLastNameOptionalOnUsers < ActiveRecord::Migration[7.0]
  def change
    change_column_null :users, :last_name, true # Allows NULL values
  end
end
