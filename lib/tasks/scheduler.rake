desc "Tasks called by the Heroku scheduler add-on"
task update_contracts: :environment do
  puts "Updating contracts..."
  Request.update_contracts
  puts "done."
end

task update_requests: :environment do
  puts "Checking requests expiring date"
  Request.update_requests
  puts "done."
end
