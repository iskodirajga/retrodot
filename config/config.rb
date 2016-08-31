require 'configerator'

module Config
  extend Configerator

  # required :something
  # optional :anotherthing
  # override :port, 3000, int

  required :source_url, string
  override :app_name, "retrodot", string
  override :frontend_host, "retro.dev", string

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

  optional :email_cc, string

  # Admin UI configuration
  override :localize_format, :long, symbol

  # Auth
  override :pr_app, false, bool
  optional :google_client_id, string
  optional :google_client_secret, string
  optional :google_domain, string
  optional :chatops_api_key, string

  override :max_words_in_name, 2, int
end
