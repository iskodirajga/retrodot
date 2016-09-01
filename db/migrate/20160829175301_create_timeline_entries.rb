class CreateTimelineEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :timeline_entries do |t|
      t.datetime :timestamp
      t.belongs_to :user
      t.belongs_to :incident
      t.text :message

      t.timestamps
    end
    add_index :timeline_entries, :timestamp
  end
end
