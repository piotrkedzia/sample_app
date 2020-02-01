require 'factory_bot'

FactoryBot.create(:user, admin: true)

100.times do
  FactoryBot.create(:user)
end

# Following relationships
users = User.all
user = users.first
following = users[2..50]
followers = users[3..40]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }
