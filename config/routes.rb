Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  post "/incidents/sync" => "incidents#sync"

  root to: 'incidents#index'

  resource :auth, controller: 'auth', only: :index do
    match "/:provider/callback" => "auth#callback", via: %i[get post]
    get :logout, as: 'logout'
    get :unauthorized
    get :verify
    get :failure
  end

  namespace :api, defaults: {format: 'json'} do
    namespace :chatops do
      get 'v1/matcher'
      post 'v1/respond'
    end
  end
end
