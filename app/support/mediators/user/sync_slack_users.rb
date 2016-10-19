require 'slack'

module Mediators::User
  class SyncSlackUsers < Mediators::Base

    def initialize(token:)
      @client = Slack::Client.new token: token
    end

    def call
      log action: 'syncing'
      users.each do |user|
        ::User.ensure(user) unless user[:email].blank?
      end
    end

    private

    def users
      @client.users_list["members"].map do |u|
        { handle:        u["handle"],
          name:          u["name"],
          email:         u["profile"]["email"],
          slack_user_id: u["id"]
         }
      end
    end

  end
end
