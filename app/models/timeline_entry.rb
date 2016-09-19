class TimelineEntry < ApplicationRecord
  belongs_to :user
  belongs_to :incident

  default_value_for :timestamp do
    Time.now
  end
end
