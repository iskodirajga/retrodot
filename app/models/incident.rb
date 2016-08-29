class Incident < ActiveRecord::Base
  has_many :retrospectives
  has_many :remediations, through: :retrospectives
  belongs_to :category
  has_many :timeline_entries
end
