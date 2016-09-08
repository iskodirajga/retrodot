class AddTimelineStartAndLastSyncToIncident < ActiveRecord::Migration[5.0]
  def change
    add_column :incidents, :timeline_start, :datetime
    add_index :incidents, :timeline_start

    add_column :incidents, :last_sync, :datetime
    add_index :incidents, :last_sync
  end
end
