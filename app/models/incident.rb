class Incident < ActiveRecord::Base
  has_many :retrospectives
  has_many :remediations, through: :retrospectives
end
