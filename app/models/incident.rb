class Incident < ActiveRecord::Base
  has_many :retrospectives
  has_many :remediations, through: :retrospectives
  belongs_to :category
  has_many :timeline_entries, -> { order(timestamp: :asc) }
  has_and_belongs_to_many :responders, join_table: :incidents_responders, class_name: "User"

  default_scope { order('incident_id DESC') }
  scope :open, -> { where(state: "open") }
  scope :synced, -> { where.not(last_sync: nil) }
  scope :by_timeline_start, -> { unscoped.where.not(timeline_start: nil).order('timeline_start DESC') }

  def chat_start
    super&.in_time_zone Config.time_zone
  end

  def chat_end
    super&.in_time_zone Config.time_zone
  end

  def open?
    state == "open"
  end
end
