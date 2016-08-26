class RemoveCategoryAssociationFromRetrospectives < ActiveRecord::Migration[5.0]
  def up
    remove_column :retrospectives, :category_id
  end

  def down
    add_column :retrospectives, :category_id, :integer
  end
end
