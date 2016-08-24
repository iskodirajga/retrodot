class RenameFollowup < ActiveRecord::Migration[5.0]
  def change
    rename_column :incidents, :requires_followup, :review
  end
end
