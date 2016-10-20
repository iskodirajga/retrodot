namespace :sync do
  desc "Sync data from Past Incidents spreadsheet"
  task :past_incidents, [:csv_file] => :environment do |t, args|
    csv_file = args[:csv_file] || "past_incidents.csv"
    Mediators::Incident::PastIncidentsSyncher.run(csv_file)
  end
end
