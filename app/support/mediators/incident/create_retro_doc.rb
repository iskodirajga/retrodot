require 'google/apis/script_v1'

class GoogleAuthRequired < StandardError
end

module Mediators::Incident;
  class CreateRetroDoc < Mediators::Base

    def initialize(auth:, id:, title:, trello_url:, postmortem_date: false, dev_mode: false)
      @auth, @id, @title, @trello_url, @postmortem_date, @dev_mode = auth, id, title, trello_url, postmortem_date, dev_mode

      @service = Google::Apis::ScriptV1::ScriptService.new
      @service.authorization = @auth
    end

    def call
      log(fn: :call, at: :create_retro_doc)
      resp = @service.run_script(Config.google_script_id, execution_req)
      resp.to_h[:response][:result]
    rescue Google::Apis::ClientError, Google::Apis::AuthorizationError, Signet::AuthorizationError
      log_error($!, fn: "call", at: "run", id: @id)
      raise GoogleAuthRequired
    end

    def execution_req
      Google::Apis::ScriptV1::ExecutionRequest.new(function: Config.google_script_function, dev_mode: @dev_mode, parameters: [ @id, @title, @trello_url, @postmortem_date ])
    end

  end
end
