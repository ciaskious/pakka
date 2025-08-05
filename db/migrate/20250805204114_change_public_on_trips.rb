class ChangePublicOnTrips < ActiveRecord::Migration[7.1]
  def up
    change_column_default :trips, :public, from: nil, to: true
    change_column_null :trips, :public, true, true
  end

  def down
    change_column_null :trips, :public, true
    change_column_default :trips, :public, from: false, to: nil
  end
end
