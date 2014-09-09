# encoding: utf-8

namespace :scheduled do

  #Usage
  #Development:   bundle exec rake scheduled:removeExpiredSessionTokens
  #In production: bundle exec rake scheduled:removeExpiredSessionTokens RAILS_ENV=production
  task :removeExpiredSessionTokens => :environment do
    puts "Removing expired session tokens"
    SessionToken.deleteExpiredTokens
    puts "Finish"
  end

end
