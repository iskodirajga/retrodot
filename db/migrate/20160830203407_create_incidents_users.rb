class CreateIncidentsUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :incidents_users, id: false do |t|
      t.belongs_to :incident, index: true
      t.belongs_to :user, index: true
    end
  end
end
