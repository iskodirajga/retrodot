module ChatOps
  module IncidentHelpers
    def current_incident
      Incident.by_timeline_start.first
    end

    def determine_incident(id)
      if id
        Incident.find_by(incident_id: id)
      else
        current_incident
      end
    end
  end
end
