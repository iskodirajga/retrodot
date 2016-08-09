class Category < ActiveRecord::Base
  has_many :retrospectives
end
