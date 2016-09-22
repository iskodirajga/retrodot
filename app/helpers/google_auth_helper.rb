require 'googleauth'

module AuthHelper
  class GoogleAuthHelper
    include Loggerator

    def initialize(client_id:, client_secret:, refresh_token:, auth_code:)
      # In order to properly auth with the Google Drive API and still use omniauth
      # to perform the oauth dance, we need to create an instance of UserRefreshCredentials
      # and feed it an authorization code, along with the refresh_token if it exists in the response.
      @google_auth ||= Google::Auth::UserRefreshCredentials.new(
        client_id:     client_id,
        client_secret: client_secret,
        refresh_token: refresh_token,
        code:          auth_code
      )
    end

    def session
      @google_auth.fetch_access_token!
    rescue Signet::AuthorizationError
      log_error($!, at: :fetch_access_token!, fn: :session)
      raise
    end

  end
end
