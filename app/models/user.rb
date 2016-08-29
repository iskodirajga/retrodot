class User < ApplicationRecord
  has_many :timeline_entries
end
