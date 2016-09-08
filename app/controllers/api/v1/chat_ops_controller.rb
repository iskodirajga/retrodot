class Api::V1::ChatOpsController < ApplicationController
  skip_before_action :verify_authenticity_token
  http_basic_authenticate_with name: "api", password: Config.chatops_api_key

  def matcher
    render json: {"regex": ChatOps.matcher}
  end

  def respond
    user = User.ensure(**params['user'].slice('email', 'name', 'handle').symbolize_keys)
    result = ChatOps.process(user, params['message'])

    if result
      render json: result
    else
      render status: :not_found, json: {"error": "command not found"}
    end
  end
end
