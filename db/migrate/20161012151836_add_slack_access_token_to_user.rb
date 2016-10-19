class AddSlackAccessTokenToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :slack_access_token, :string
  end
end
