class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  protected

  def authenticate_user
    Rails.logger.debug(fn: 'authenticate_user')
    authentication_failure! unless current_user
  end

  def current_user
    Rails.logger.debug(fn: "current_user")
    if session[:user]
      Rails.logger.debug(fn: "current_user", at: "find_user", email: session[:user][:email])
      # ActiveAdmin looks up the wrong namespace for User, so we have to prepend with ::
      @user ||= ::User.find_by(email: session[:user][:email])
    end
  end

  def authentication_failure!
    Rails.logger.debug(fn: 'authentication_failure!')

    session[:return_to] = request.path

    respond_to do |format|
      format.html { redirect_to('/auth/unauthorized') }
      format.js   { redirect_to('/auth/unauthorized') }
      format.json { render text: 'Authentication Required', status: 401 }
    end
  end
end
