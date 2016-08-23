namespace :sync do
  desc "Sync incident via the Syncher Mediator"
  task :incident, [:incident_id] => :environment do |t, args|
    args[:incident_id] ? Mediators::Incident::OneSyncher.run(id: args[:incident_id]) : Mediators::Incident::MultiSyncher.run
  end
end
