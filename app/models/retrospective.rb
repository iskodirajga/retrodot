class Retrospective < ActiveRecord::Base
  has_many   :remediations
  belongs_to :incident
  belongs_to :category

  validates :incident, :created_on, :description, presence: true
end
