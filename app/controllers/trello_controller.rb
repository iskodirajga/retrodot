class TrelloController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def create
    return redirect_to "/auth/failure" unless current_user

    session['trello-oauth-token']  = auth_hash["credentials"]["token"]
    session['trello-oauth-secret'] = auth_hash["credentials"]["secret"]

    log(fn: "create", at: "update_oauth", user: session[:user][:email])
    current_user.update(trello_oauth_token: session['trello-oauth-token'], trello_oauth_secret: session['trello-oauth-secret'])

    redirect_to(session.delete(:return_to))
  end

  protected
  def auth_hash
    request.env['omniauth.auth']
  end
end
