class User < ApplicationRecord
  has_and_belongs_to_many :incidents, join_table: :incidents_responders
  has_many :timeline_entries
  validates :handle, format: { with: /\A[-_.a-z0-9]+\z/, message: "only allows numbers, lowercase letters, dashes, periods and underscores" }, allow_nil: true

  scope :with_handle, -> { where.not(handle: [nil, ""]) }

  def as_json(options={})
    {
      name: name,
      email: email,
      handle: handle
    }
  end

  class << self
    def ensure(email:, name: nil, handle: nil, slack_user_id: nil)
      user               = find_or_create_by(email: email)
      user.name          = name
      user.handle        = handle
      user.slack_user_id = slack_user_id
      user.save!

      user
    end
  end
end
