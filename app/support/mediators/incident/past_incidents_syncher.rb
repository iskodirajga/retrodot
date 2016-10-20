module Mediators::Incident
  class PastIncidentsSyncher < Mediators::Base
    ID_COLUMN = "@"
    CATEGORY_COLUMN = "Category"
    TEAM_COLUMN = "Primary Team"
    RETRO_DATE_COLUMN = "Date of Retro"

    def initialize(csv_file)
      @csv_file = csv_file
    end

    def call
      CSV.foreach(@csv_file, headers: true) do |row|
        id = row[ID_COLUMN]
        category_name = row[CATEGORY_COLUMN]
        team_name = row[TEAM_COLUMN]
        retro_date = DateTime.strptime(row[RETRO_DATE_COLUMN], '%m/%d/%Y') rescue nil

        log id: id

        if id !~ /^\d+$/
          log warning: "Skipping due to invalid incident ID", row: row.to_hash
          next
        end

        category = ::Category.find_or_create_by(name: category_name) if category_name
        team = ::Team.find_or_create_by(name: team_name)
        incident = Incident.find_or_create_by(incident_id: id)

        incident.primary_team = team
        incident.category = category
        incident.retro_at = retro_date
        incident.save
      end
    end
  end
end
