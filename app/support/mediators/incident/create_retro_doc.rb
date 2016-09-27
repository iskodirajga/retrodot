require 'google/apis/script_v1'

module Mediators::Incident
  class CreateRetroDoc < Mediators::Base

    def initialize(auth:, id:, title:, postmortem_date: false, dev_mode: true)
      @auth, @id, @title, @postmortem_date, @dev_mode = auth, id, title, postmortem_date, dev_mode

      @service = Google::Apis::ScriptV1::ScriptService.new
      @service.authorization = @auth
    end

    def call
      log(fn: :call, at: :create_retro_doc)

      resp = @service.run_script(Config.google_script_id, execution_req)
    rescue Google::Apis::ClientError
      log_error($!, fn: "call", at: "run", id: @id)
      raise
    end

    def execution_req
      Google::Apis::ScriptV1::ExecutionRequest.new(function: Config.google_script_function, dev_mode: @dev_mode, parameters: { id: @id, title: @title, postmortem_date: @postmortem_date })
    end

  end
end
