Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  post "/incidents/sync" => "incidents#sync"

  root to: 'incidents#index'

  get '/auth/trello/callback', to: 'trello#create'

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
      post 'chat_ops/responder'
    end
  end

end
