class Api::V1::ExportController < ApplicationController
  skip_before_action :verify_authenticity_token
  http_basic_authenticate_with name: "export", password: Config.export_api_key
  respond_to :json

  def export
    limit = params.permit(:limit, :format)[:limit] || 100

    output = Incident.by_started_at.limit(100).collect do |incident|
      {
        id: incident.incident_id,
        title: incident.title,
        created_at: incident.started_at,
        resolved_at: incident.resolved_at,
        resolved: incident.state == "resolved",
        category: incident.category&.name,
        retro_at: incident.retro_at,
        primary_team: incident.primary_team&.name
      }
    end

    render json: output
  end
end
