class ChangeStatusIncidentId < ActiveRecord::Migration[5.0]
  def change
     rename_column :incidents, :status_incident_id, :incident_id
  end
end
