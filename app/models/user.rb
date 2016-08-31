class User < ApplicationRecord
  has_and_belongs_to_many :incidents
  has_many :timeline_entries
end
