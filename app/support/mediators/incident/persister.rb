module Mediators::Incident
  class Persister < Mediators::Base
    attr_accessor :incident_data

    def initialize(incident:)
      @incident_data = incident.with_indifferent_access
    end

    def call
      log(fn: "call")
      update_incident
    end

    def update_incident
      log(fn: "update_incident")
      incident = ::Incident.find_or_initialize_by(incident_id: parse_details[:incident_id])
      incident.update(parse_details.merge!(followup_on: followup_date))
    end

    def parse_details
      @parse_details ||= \
      details.each_with_object({}) do |attr, hsh|
        hsh[attr] = incident_data[Config.send(attr)]
      end.with_indifferent_access
    end

    private
    def followup_date
      Config.followup_days.days.from_now(DateTime.parse(parse_details[:started_at])) if parse_details[:review]
    end

    def details
      %w[incident_id state title started_at resolved_at duration review]
    end
  end
end
