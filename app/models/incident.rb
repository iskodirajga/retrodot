class Incident < ActiveRecord::Base
  has_many :retrospectives
  has_many :remediations, through: :retrospectives
  belongs_to :category
  has_many :timeline_entries, -> { order(timestamp: :asc) }
  has_and_belongs_to_many :responders, -> { distinct }, join_table: :incidents_responders, class_name: "User"

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

  def format_timeline
    timeline_entries.map {|t| "#{t.timestamp.utc} #{t.user.name}: #{t.message}"}.join("\n")
  end

  def retro_prepared?
    trello_url && google_doc_url
  end

  def missing_timeline?
    timeline_entries.blank?
  end

  # This method helps detect whether the user meant to refer to this incident.
  def old?
    # they specifically told us via chatops that they were done, so they
    # probably don't mean this one
    return true if chat_end

    # the incident is still open in the external incident source, so they
    # probably mean this one
    return false if open?

    return true if !timeline_entries.empty? && timeline_entries.last.timestamp < 1.hour.ago
    return true if timeline_entries.empty? && chat_start? && chat_start < 1.hour.ago

    false
  end

end
