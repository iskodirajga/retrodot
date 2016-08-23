class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  protected

  def authenticate_user
    authentication_failure! unless current_user
  end

  def current_user
    if session[:user]
      User.find_by(email: session[:user][:email])
    end
  end
end
