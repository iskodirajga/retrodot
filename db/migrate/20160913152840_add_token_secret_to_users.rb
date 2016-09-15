class AddTokenSecretToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :trello_oauth_token, :string, null: true
    add_column :users, :trello_oauth_secret, :string, null: true
  end
end
