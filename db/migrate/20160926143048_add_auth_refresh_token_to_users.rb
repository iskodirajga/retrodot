class AddAuthRefreshTokenToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :google_refresh_token, :string
    add_column :users, :google_auth_code,     :string
  end
end
