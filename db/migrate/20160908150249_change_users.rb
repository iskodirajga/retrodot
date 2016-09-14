class ChangeUsers < ActiveRecord::Migration[5.0]
  def change
    change_column_null(:users, :name, true)
    add_index :users, :email, unique: true
  end
end
