Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer if Rails.env.development? || Config.pr_app?
  provider :google_oauth2, Config.google_client_id, Config.google_client_secret, { hd: Config.google_domain }
end
