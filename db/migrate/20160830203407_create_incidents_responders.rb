class CreateIncidentsResponders < ActiveRecord::Migration[5.0]
  def change
    create_table :incidents_responders, id: false do |t|
      t.belongs_to :incident, index: true
      t.belongs_to :user, index: true
    end
  end
end
