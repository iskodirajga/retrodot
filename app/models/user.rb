class User < ApplicationRecord
  has_and_belongs_to_many :incidents, join_table: :incidents_responders
  has_many :timeline_entries
  validates :handle, format: { with: /\A[-_.a-z0-9]+\z/, message: "only allows numbers, lowercase letters, dashes, periods and underscores" }
end
