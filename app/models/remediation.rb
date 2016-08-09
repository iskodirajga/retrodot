class Remediation < ActiveRecord::Base
  has_one    :incident, through: :retrospective
  belongs_to :retrospective
end
