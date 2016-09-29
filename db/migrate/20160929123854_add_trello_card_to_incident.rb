class AddTrelloCardToIncident < ActiveRecord::Migration[5.0]
  def change
    add_column :incidents, :trello_url, :string
  end
end
