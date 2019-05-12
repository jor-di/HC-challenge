# frozen_string_literal: true

Request.destroy_all

users = {}
7.times do |index|
  pos = index + 1
  users[pos] = Request.create!(name: "User #{pos}",
                               email: "user_#{pos}@Lorem.com",
                               biography: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',
                               phone_number: '0707070707')
end

# 1st user : unconfirmed
# 2nd user : on the waiting list
users[2].update(email_confirmed_date: Date.yesterday, request_expiring_date: Date.tomorrow)
# 3rd user : on the waiting list, with request to be reconfirmed
users[3].update(email_confirmed_date: 4.months.ago, request_expiring_date: Date.today)
# 4th user : accepted
users[4].update(email_confirmed_date: 6.months.ago, request_expiring_date: Date.tomorrow)
# 5th user : accepted with contract to renew
users[5].confirm_email!
users[5].accept!
users[5].update(contract_starting_date: 1.month.ago)
# 6th user : ready to be expired
users[6].update(email_confirmed_date: 6.months.ago, request_expiring_date: 8.days.ago)
# 7th user : expired
users[7].update(email_confirmed_date: 6.months.ago, request_expiring_date: 10.days.ago, expired: true)
