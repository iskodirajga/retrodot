class Category < ActiveRecord::Base
  has_many :incidents
end
