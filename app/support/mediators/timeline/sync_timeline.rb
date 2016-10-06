module Mediators::Timeline
  class SyncTimeline < Mediators::Base

    def call
      sync_timeline
    rescue Excon::Error
      log_error(error: $!, fn: "call", at: "run")
      raise $!
    end

    def sync_timeline
      data.each do |timeline|
        # Dealing with erroneous data
        next unless timeline.second.respond_to?(:each)

        timeline.second.each do |details|
          d = details.second
          incident = Incident.find_by(incident_id: d["id"])
          next if incident.nil?

          responders = d["people"].map {|user| User.find_by(name: user) }
          incident.responders += responders.compact unless responders.nil?

          d["timeline"].each do |entry|
            user = User.find_by(name: entry["user"])
            incident.timeline_entries << ::TimelineEntry.new(user: user, message: entry["text"], timestamp: entry["time"])
          end
        end
      end
    end

    private
    def data
      MultiJson.decode(get_timeline.body)
    end

    def get_timeline
      Excon.new("#{Config.chatops_timeline_url}").request(
        method:     :get,
        expects:    200,
        idempotent: true,
        query:      { secret: Config.chatops_timeline_api_key }
      )
    end
  end
end
