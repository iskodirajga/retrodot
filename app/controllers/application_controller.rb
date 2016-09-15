class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def current_user
    if session[:user]
      log(fn: "current_user", at: "find_user", email: session[:user][:email])
      # ActiveAdmin looks up the wrong namespace for User, so we have to prepend with ::
      @user ||= ::User.find_by(email: session[:user][:email])
    end
  end

  protected

  def authenticate_user
    log(fn: 'authenticate_user')
    authentication_failure! unless current_user
  end

  def authentication_failure!
    log(fn: 'authentication_failure!')

    session[:return_to] = request.path

    respond_to do |format|
      format.html { redirect_to('/auth/unauthorized') }
      format.js   { redirect_to('/auth/unauthorized') }
      format.json { render text: 'Authentication Required', status: 401 }
    end
  end
end
