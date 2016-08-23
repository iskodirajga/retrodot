module Mediators::Incident
  class MultiSyncher < Mediators::Base
    include Helpers::Paginator

    def call
      fetch(Config.source_url).each do |incident|
        Mediators::Incident::Persister.run(incident: incident)
      end
    rescue Excon::Error
      Rails.logger.error($!, fn: "call", at: "run", incident_id: incident[Config.incident_id])
      raise $!
    end
  end
end
