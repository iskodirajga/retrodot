class MessagesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def create
    return render_error("Invalid Token", 401) unless valid_slack_token?

    user = User.find_by(slack_user_id: message[:user_id])
    return render_error("Slack `user_id` not found in retrodot", 403) unless user

    result = ChatOps.process(user, message[:text]) || "command unknown, try `/timeline help`"

    render json: { text: result, response_type: "in_channel" }, status: 200
  end

  private

  def valid_slack_token?
    ActiveSupport::SecurityUtils.secure_compare(message[:token], Config.slack_slash_command_token) rescue false
  end

  def message
    params.permit(:text, :token, :user_id, :command).to_h.symbolize_keys
  end

  def render_error(error, code)
    render json: { text: error, response_type: "in_channel" }, status: code
  end
end
