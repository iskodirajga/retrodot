require 'googleauth'

module AuthHelper
  class GoogleAuth
    include Loggerator

    def initialize(client_id:, client_secret:, refresh_token:, auth_code:)
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
