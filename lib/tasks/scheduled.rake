# encoding: utf-8

namespace :scheduled do

  #How to use: bundle exec rake scheduled:updateContext
  #In production: bundle exec rake scheduled:updateContext RAILS_ENV=production
  task :updateContext => :environment do |t, args|
    puts "Updating LOEP context"
    Rake::Task["metadata:updateMetadataFieldRecords"].invoke
    Rake::Task["metadata:updateGraphs"].invoke
    Rake::Task["interactions:updateThresholds"].invoke
    puts "Task finished"
  end

  #Usage
  #Development:   bundle exec rake scheduled:removeExpiredSessionTokens
  #In production: bundle exec rake scheduled:removeExpiredSessionTokens RAILS_ENV=production
  task :removeExpiredSessionTokens => :environment do
    puts "Removing expired session tokens"
    SessionToken.deleteExpiredTokens
    puts "Finish"
  end

end