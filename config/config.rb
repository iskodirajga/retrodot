require 'configerator'

module Config
  extend Configerator

  # required :something
  # optional :anotherthing
  # override :port, 3000, int

  override :frontend_host, "retro.dev", string
  required :source_url, string

  # Overrides for incident syncher
  override :duration, "duration", string
  override :incident_id, "incident_id", string
  override :state, "state", string
  override :title, "title", string
  override :started_at, "started_at", string
  override :resolved_at, "resolved_at", string
  override :incident_id, "incident_id", string
  override :requires_followup, "requires_followup", string

  override :followup_days, 5, int
end
