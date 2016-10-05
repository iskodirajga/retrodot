require 'trello'
module Mediators::Incident
  class EditCard < Mediators::Base

    def initialize(id:, card_id:, gdoc:, trello_oauth_token:, trello_oauth_secret:)
      @id, @card_id, @gdoc, @oauth_token, @oauth_secret = id, card_id, gdoc, trello_oauth_token, trello_oauth_secret
    end

    def call
      log(fn: :call, at: :edit_trello_card)

      @trello = Trello::Client.new(
        consumer_key:       Config.trello_consumer_key,
        consumer_secret:    Config.trello_consumer_secret,
        oauth_token:        @oauth_token,
        oauth_token_secret: @oauth_secret
      )

      @card = @trello.find(:card, @card_id)
      @card.desc = update_description
      @card.update!

      @card
    rescue Trello::InvalidAccessToken, Trello::Error, NoMethodError
      log_error($!, fn: "call", at: "run", card_id: @card_id)
      raise
    end

    def update_description
      "[Heroku status incident](https://status.heroku.com/admin/incidents/#{@id})\n\n" \
      "[Gdoc notes](#{@gdoc})\n\n"
    end
  end
end
