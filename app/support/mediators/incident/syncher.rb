module Mediators::Incident
  class Syncher < Mediators::Base
    def call
      Rails.logger.info(fn: "call")
      update_incident

    rescue Excon::Error
      Rails.logging.error($!, fn: "call", at: "update_incident", incident_id: @options[:incident])
      raise $!
    end

    def incident_details
      @response ||= response
    end

    def get_incident
      Excon.new("#{Config.source_url}/#{@options[:incident]}").request(
        method:       :get,
        expects:      200,
        idempotent:   true,
      )
    end

    def update_incident
      Rails.logger.info(fn: "update_incident")

      @incident = ::Incident.find_or_initialize_by(incident_id: parse_details[:incident_id])
      @incident.update(parse_details.merge!(followup_on: followup_date))
    end

    private
    def response
      MultiJson.decode(get_incident.body)
    end

    def followup_date
      Config.followup_days.business_days.after(DateTime.parse(incident_details[Config.started_at]))
    end

    def parse_details
      @parse_details ||= \
        details.each_with_object({}) do |attr, hsh|
          hsh[attr] = incident_details[Config.send(attr.to_sym)]
        end.with_indifferent_access
    end

    def details
      %w[incident_id state title started_at resolved_at duration requires_followup]
    end
  end
end
