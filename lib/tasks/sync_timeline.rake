namespace :sync do
  desc "Sync Timeline from ChatOps"
  task :timeline => :environment do |t|
    Mediators::Timeline::SyncTimeline.run
  end
end
