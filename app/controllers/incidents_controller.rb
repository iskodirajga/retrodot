class IncidentsController < ApplicationController
  protect_from_forgery except: :sync

  def index
    render text: "Welcome to Retrodot"
  end

  def sync
    logger.info(ns: self.class.name, fn: :sync, incident: params["incident_id"])

    if Mediators::Incident::Syncher.run(incident: params['incident_id'])
      render json: nil, status: 202
    else
      render json: nil, status: 500
    end
  end

  private
  def check_params
    params.require(:incident_id)
  end
end
