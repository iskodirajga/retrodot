namespace :sync do
  desc "Sync users from ChatOps"
  task :users => :environment do |t|
    Mediators::User::Sync.run
  end
end
