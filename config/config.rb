require 'configerator'

module Config
  extend Configerator

  # required :something
  # optional :anotherthing
  # override :port, 3000, int

  override :app_name, "Retrodot", string

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
  override :review, "review", string

  override :followup_days, 5, int

  # Admin UI configuration
  override :localize_format, :long, symbol

  # Auth
  override :pr_app, false, bool
  optional :google_client_id, string
  optional :google_client_secret, string
  optional :google_domain, string
end
