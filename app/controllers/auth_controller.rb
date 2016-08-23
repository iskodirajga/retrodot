class AuthController < ApplicationController
  skip_before_action :authenticate_user, except: :verify

  # this is the only spot where we allow CSRF, our oauth redirect will not have
  # a CSRF token, however the payload is all validated so it's safe
  skip_before_action :verify_authenticity_token, only: :callback

  def callback
    unless session['user'].present?
      user = env['omniauth.auth']['info']

      email = (user['email']||'').downcase
      name = user['name']

      unless valid_email? email
        redirect_to failure_auth_path
        return
      end

      session[:user] = {
        email: email
      }

      # Not using the block form of find_or_create_by here, because I always
      # want to sync their name with what's set in the provider.
      User.find_or_create_by(email: email).update(name: name)

      flash[:notice] = "Logged in."
    end

    origin = session.delete(:return_to)
    redirect_to (origin && origin !~ %r{/auth/} ? origin : root_path)
  end

  def logout
    reset_session
    render :text => "You're logged out."
  end

  def unauthorized
    return_to = session[:return_to]
    reset_session
    session[:return_to] = return_to

    redirect_to "/auth/#{auth_provider}"
  end

  def failure
    render text: "You are not authorized", status: 401
  end

  def verify
    head(:ok)
  end

  protected
  def auth_provider
    if Rails.env.development? or Config.pr_app?
      :developer
    else
      :google_oauth2
    end
  end

  def valid_email? email
    !!(email =~ %r[@#{Config.google_domain}$])
  end
end
