module Mediators::User
  class Sync < Mediators::Base
    def call
      log action: 'syncing', source: Config.chatops_users_url
      users.each do |chatops_user|
        log action: 'syncing', user: chatops_user
        if chatops_user['email']
          ::User.ensure(**chatops_user.slice('email', 'name', 'handle').symbolize_keys)
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
