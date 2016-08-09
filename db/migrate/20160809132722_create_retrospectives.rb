class CreateRetrospectives < ActiveRecord::Migration[5.0]
  def change
    create_table :retrospectives do |t|
      t.datetime   :created_on
      t.string     :description
      t.timestamps null: false

      t.belongs_to :incident
      t.belongs_to :category
    end
  end
end
