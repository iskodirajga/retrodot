class Api::V1::ChatOpsController < ApplicationController
  skip_before_action :verify_authenticity_token
  http_basic_authenticate_with name: "api", password: Config.chatops_api_key

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

  private
  def user_params
    params.require(:user).permit(:email, :name, :handle).to_h.symbolize_keys
  end

  def message_params
    params.require(:message)
  end

  require_all 'lib/chat_ops/commands/**.rb'
end
