require 'configerator'

module Config
  extend Configerator

  # required :something
  # optional :anotherthing
  # override :port, 3000, int

  required :source_url, string
  override :app_name, "retrodot", string
  override :frontend_host, "retro.dev", string
  override :time_zone, "US/Pacific", string

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
  optional :chatops_users_url, string
  optional :chatops_users_api_key, string
  optional :chatops_timeline_url, string
  optional :chatops_timeline_api_key, string
  optional :trello_consumer_key, string
  optional :trello_consumer_secret, string
  optional :trello_template, string

  # Google Script id for rest execution API
  # https://developers.google.com/apps-script/execution
  optional :google_script_id, string
  optional :google_script_function, string

  # Mailer
  optional :mailgun_smtp_server, string
  optional :mailgun_smtp_port, string
  optional :mailgun_domain, string
  optional :mailgun_smtp_login, string
  optional :mailgun_smtp_password, string
end
