Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer if Rails.env.development? || Config.pr_app?
  provider :google_oauth2, Config.google_client_id, Config.google_client_secret, { hd: Config.google_domain }
  provider :trello, Config.trello_consumer_key, Config.trello_consumer_secret, app_name: Config.app_name, scope: "read,write,account", expiration: "never"
end
