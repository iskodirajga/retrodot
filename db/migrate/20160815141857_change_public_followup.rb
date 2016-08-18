class ChangePublicFollowup < ActiveRecord::Migration[5.0]
  def change
      rename_column :incidents, :public_followup,    :requires_followup
      rename_column :incidents, :public_followup_on, :followup_on
  end
end
