require "slack"
class Api::V1::IncidentsController < ApplicationController
  skip_before_action :verify_authenticity_token
  protect_from_forgery except: :sync
  before_action :get_incident

  def sync
    # Start an incident and post to slack if an incident currently exists
    # without a timeline and is not an update of type scheduled / maintenance.
    if @incident&.missing_timeline? && start_incident?
      render json: nil, status: 202
    elsif !@incident
      # If the incident does not exist, first sync before starting the incident.
      Mediators::Incident::OneSyncher.run(id: params[:incident_id])
      status = start_incident?? 202 : 403
      render json: nil, status: status
    else
      render json: nil, status: 403
    end
  end

  private
  def start_incident?
    allowed_update_type?? post_to_slack : false
  end

  def allowed_update_type?
    !%w[scheduled maintenance].include?(params[:update_type])
  end

  def start_incident
    ChatOps::Commands::StartIncidentCommand.process(nil, "start incident #{params[:incident_id]}")[:message]
  end

  def post_to_slack
    c = Slack::Client.new token: slack_token
    c.chat_postMessage(
      channel:  Config.slack_bot_channel,
      username: Config.slack_bot_username,
      text:     start_incident
    )

    true
  end

  def slack_token
    User.with_slack_token.first.slack_access_token
  end

  def check_params
    params.permit(:incident_id, :update_type)
  end

  def get_incident
    @incident = Incident.find_by(incident_id: params[:incident_id])
  end
end
