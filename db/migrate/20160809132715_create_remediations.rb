class CreateRemediations < ActiveRecord::Migration[5.0]
  def change
    create_table :remediations do |t|
      t.datetime   :created_on
      t.string     :description
      t.boolean    :completed
      t.string     :pull_request
      t.timestamps null: false

      t.belongs_to :retrospective
    end
  end
end
