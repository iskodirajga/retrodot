class AddIncidentAssociationToCategory < ActiveRecord::Migration[5.0]
  def up
    add_column :incidents, :category_id, :integer
    add_index  :incidents, ['category_id']
  end

  def down
    remove_column :incidents, :category_id
  end
end
