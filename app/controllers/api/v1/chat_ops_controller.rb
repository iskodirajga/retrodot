class Api::V1::ChatOpsController < ApplicationController
  skip_before_action :verify_authenticity_token
  http_basic_authenticate_with name: "api", password: Config.chatops_api_key, except: :message

  def matcher
    render json: {"regex": ChatOps.matcher}
  end

  def respond
    user   = User.ensure(user_params)
    result = ChatOps.process(user, message_params)

    if result
      render json: result
    else
      render status: :not_found, json: {"error": "command not found"}
    end
  end

  def message
    return render_error("Invalid Token", 401) unless valid_slack_token?

    user = User.find_by(slack_user_id: chat_params[:user_id])
    return render_error("Slack `user_id` not found in retrodot", 403) unless user

    result = ChatOps.process(user, chat_params[:text])
    msg, type = format_result(result)

    render json: { text: msg, response_type: type }, status: 200
  end

  private

  def format_result(result)
    return default_message,   "ephemeral"   unless result
    return result[:reaction], "ephemeral"   if result[:reaction]
    return result[:message],  "in_channel"  if result[:message]
  end

  def default_message
    "command unknown, try `#{chat_params[:command]} help`"
  end

  def valid_slack_token?
    ActiveSupport::SecurityUtils.secure_compare(chat_params[:token], Config.slack_slash_command_token) rescue false
  end

  def chat_params
    params.permit(:text, :token, :user_id, :command).to_h.symbolize_keys
  end

  def render_error(error, code)
    render json: { text: error, response_type: "ephemeral" }, status: code
  end

  def user_params
    params.require(:user).permit(:email, :name, :handle).to_h.symbolize_keys
  end

  def message_params
    params.require(:message)
  end
end
