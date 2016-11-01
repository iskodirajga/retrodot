class Api::V1::ChatOpsController < ApplicationController
  skip_before_action :verify_authenticity_token
  http_basic_authenticate_with name: "api", password: Config.chatops_api_key, except: :slack_slash_command

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

  def slack_slash_command
    return render_error("Invalid Token", 401) unless valid_slack_token?

    user = User.find_by(slack_user_id: chat_params[:user_id])
    return render_error("Slack `user_id` not found in retrodot", 403) unless user

    result = ChatOps.process(user, chat_params[:text])

    render json: fmt_result(result), status: 200
  end

  private
  def fmt_response(cmd:, response_type: :ephemeral, attach_txt: nil)
    response = {"response_type": response_type, "text": cmd}
    atm = [{"text": attach_txt, "mrkdwn_in": ["text"]}]
    response["attachments"] = atm if attach_txt

    response
  end

  def fmt_result(result)
    # Return help or unrecognized commands as an attachment
    # only visible to the sender, including the original command sent
    return fmt_response(cmd: chat_params[:text], attach_txt: default_message)  unless result
    return fmt_response(cmd: chat_params[:text], attach_txt: result[:message]) if help?

    # Return commands publicly, not as an attachment
    return fmt_response(cmd: result[:reaction], response_type: "in_channel")   if result[:reaction]
    return fmt_response(cmd: result[:message], response_type: "in_channel")    if result[:message]
  end

  def help?
    chat_params[:text] == "help"
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
