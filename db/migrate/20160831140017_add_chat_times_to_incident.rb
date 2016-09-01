class AddChatTimesToIncident < ActiveRecord::Migration[5.0]
  def change
    add_column :incidents, :chat_start, :datetime
    add_column :incidents, :chat_end, :datetime
  end
end
