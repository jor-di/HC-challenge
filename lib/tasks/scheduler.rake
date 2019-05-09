desc "Tasks called by the Heroku scheduler add-on"
task renew_contracts: :environment do
  puts "Updating contracts..."
  Request.renew_contracts
  puts "done."
end

task reconfirm_requests: :environment do
  puts "Checking requests expiring date"
  Request.reconfirm_requests
  puts "done."
end
