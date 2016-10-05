class AddRetroDocToIncident < ActiveRecord::Migration[5.0]
  def change
    add_column :incidents, :google_doc_url, :string
  end
end
