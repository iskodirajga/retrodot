class AuthController < ApplicationController
  # this is the only spot where we allow CSRF, our oauth redirect will not have
  # a CSRF token, however the payload is all validated so it's safe
  skip_before_action :verify_authenticity_token, only: :callback

  def callback
    Rails.logger.debug(fn: 'callback')
    unless session['user'].present?
      user = request.env['omniauth.auth']['info']

      email = (user['email']||'').downcase
      name = user['name']

      if params['provider'] != 'developer' && !valid_email?(email)
        Rails.logger.debug(fn: 'callback', at: 'failure')

        redirect_to failure_auth_path
        return
      end

      session[:user] = {
        email: email
      }

      # The update ensures that their name in Retrodot is synced with changes
      # in the oauth provider.
      User.create_with(name: name).find_or_create_by(email: email).update(name: name)

      flash[:notice] = 'Logged in.'
    end

    origin = session.delete(:return_to)
    redirect_to (origin && origin !~ %r{/auth/} ? origin : root_path)
  end

  def logout
    reset_session
    render plain: "You're logged out."
  end

  def unauthorized
    return_to = session[:return_to]
    reset_session
    session[:return_to] = return_to

    redirect_to "/auth/#{auth_provider}"
  end

  def failure
    render text: 'You are not authorized', status: 401
  end

  def verify
    head(:ok)
  end

  protected
  def auth_provider
    Rails.env.development? || Config.pr_app? ? :developer : :google_oauth2
  end

  def valid_email? email
    !!(email =~ %r[@#{Config.google_domain}$])
  end
end
