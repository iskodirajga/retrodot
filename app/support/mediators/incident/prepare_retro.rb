class GoogleAuthRequired < StandardError; end
class TrelloAuthRequired < StandardError; end

module Mediators::Incident
  class PrepareRetro < Mediators::Base

    def initialize(incident:, current_user:)
      @incident, @current_user = incident, current_user
    end

    def call
      @trello = Mediators::Incident::CreateCard.run(
        id:                  @incident.incident_id,
        title:               @incident.title,
        trello_oauth_token:  @current_user.trello_oauth_token,
        trello_oauth_secret: @current_user.trello_oauth_secret
      )

      @auth = Google::Auth::UserRefreshCredentials.new(
        client_id:     Config.google_client_id,
        client_secret: Config.google_client_secret,
        refresh_token: @current_user.google_refresh_token,
        code:          @current_user.google_auth_code
      )

      @gdoc = Mediators::Incident::CreateRetroDoc.run(
        auth:            @auth,
        id:              @incident.incident_id,
        title:           @incident.title,
        postmortem_date: @incident.followup_on,
        trello_url:      @trello.url
      )

      Mediators::Incident::EditCard.run(
        id:                  @incident.incident_id,
        card_id:             @trello.id,
        gdoc:                @gdoc,
        trello_oauth_token:  @current_user.trello_oauth_token,
        trello_oauth_secret: @current_user.trello_oauth_secret
      )

      @incident.update(trello_url: @trello.url, google_doc_url: @gdoc)

    rescue Signet::AuthorizationError, Google::Apis::ClientError, Google::Apis::AuthorizationError
      log_error($!, fn: "call", at: "CreateRetroDoc", incident: @incident.id)
      raise GoogleAuthRequired
    rescue Trello::InvalidAccessToken, Trello::Error, NoMethodError
      log_error($!, fn: "call", at: "CreateCard", incident: @incident.id)
      raise TrelloAuthRequired
    end
  end
end
