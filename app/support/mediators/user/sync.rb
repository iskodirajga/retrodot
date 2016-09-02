module Mediators::User
  class Sync < Mediators::Base
    def call
      users.each do |chatops_user|
        if chatops_user['email']
          user = ::User.find_or_initialize_by(email: chatops_user['email'])
          user.name = chatops_user['name'] || ""
          puts chatops_user['handle']
          user.handle = chatops_user['handle'] if chatops_user['handle']
          user.save!
        end
      end
    end

    private
    def users
      excon = Excon.new(Config.chatops_users_url)
      result = excon.request(method: :get,
                             query: {secret: Config.chatops_users_api_key},
                             expects: 200,
                             idempotent: true)
      MultiJson.decode(result.body)
    end
  end
end
