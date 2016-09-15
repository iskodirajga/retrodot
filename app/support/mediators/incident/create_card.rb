require 'trello'
module Mediators::Incident
  class CreateCard < Mediators::Base

    def initialize(id:, title:, trello_oauth_token:, trello_oauth_secret:)
      @id, @title, @oauth_token, @oauth_secret = id, title, trello_oauth_token, trello_oauth_secret
    end

    def call
      log(fn: :call, at: :create_trello_card)

      @trello = Trello::Client.new(
        consumer_key:       Config.trello_consumer_key,
        consumer_secret:    Config.trello_consumer_secret,
        oauth_token:        @oauth_token,
        oauth_token_secret: @oauth_secret
      )

      @template ||= @trello.find(:card, Config.trello_template)

      @trello.create(:card,
        "name"         => "Incident #{@id}: #{@title}",
        "idCardSource" => @template.id,
        "idList"       => @template.list_id
      )
    rescue Trello::InvalidAccessToken, Trello::Error, NoMethodError
      log_error($!, fn: "call", at: "run", id: @id)
      raise
    end
  end
end
