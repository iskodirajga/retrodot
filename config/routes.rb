Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  post "/incidents/sync" => "incidents#sync"

  root to: 'incidents#index'

  get '/auth/trello/callback', to: 'trello#create'

  # Slack callack for token creation
  get  "/auth/slack_install/callback", to: "auth#install_slack"

  resource :auth, controller: 'auth', only: :index do
    match "/:provider/callback" => "auth#callback", via: %i[get post]
    get :logout, as: 'logout'
    get :unauthorized
    get :verify
    get :failure
  end

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      get  'chat_ops/matcher'
      post 'chat_ops/respond'
      post "chat_ops/slack_slash_command"
    end
  end

end
