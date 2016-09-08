module Mediators::Incident
  class OneSyncher < Mediators::Base
    attr_accessor :id

    def initialize(id:)
      @id = id
    end

    def call
      Mediators::Incident::Persister.run(incident: payload)
    rescue Excon::Error
      log_error(error: $!, fn: "call", at: "run", incident_id: id)
      raise $!
    end

    private
    def payload
      MultiJson.decode(get_incident.body)
    end

    def get_incident
      Excon.new("#{Config.source_url}/#{id}").request(method: :get, expects: 200, idempotent: true)
    end

  end
end
