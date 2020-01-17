require 'factory_bot'

FactoryBot.create(:user, admin: true)

100.times do
  FactoryBot.create(:user)
end
