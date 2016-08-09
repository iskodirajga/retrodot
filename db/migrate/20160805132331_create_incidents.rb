class CreateIncidents < ActiveRecord::Migration[5.0]
  def change
    create_table :incidents do |t|
      t.datetime   :started_at
      t.datetime   :resolved_at
      t.integer    :duration
      t.string     :state
      t.string     :title
      t.integer    :status_incident_id
      t.boolean    :public_followup
      t.date       :public_followup_on
      t.timestamps null: false
    end
  end
end
