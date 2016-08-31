class Incident < ActiveRecord::Base
  has_many :retrospectives
  has_many :remediations, through: :retrospectives
  belongs_to :category
  has_many :timeline_entries
  has_and_belongs_to_many :responders, join_table: :incidents_responders, class_name: "User"
end
