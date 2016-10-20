class AddFieldsToIncident < ActiveRecord::Migration[5.0]
  def change
    add_column :incidents, :retro_at, :timestamp
    add_reference :incidents, :primary_team, index: true, foreign_key: {to_table: :teams}
  end
end
