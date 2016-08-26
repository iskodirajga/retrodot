class Api::Chatops::V1Controller < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :check_api_key

  def matcher
    render json: {"regex": ChatOps.matcher}
  end

  def respond
    result = ChatOps.process(params['user'], params['message'])

    if result
      render json: result
    else
      render status: :not_found, json: {"error": "command not found"}
    end
  end

  private
    def check_api_key
      unless params['API_KEY'] == Config.chatops_api_key
        render status: :forbidden, json: {"error": "invalid api key"}
      end
    end
end
