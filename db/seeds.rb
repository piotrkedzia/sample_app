require 'factory_bot'

create(:user, admin: true)

100.times do
  FactoryBot.create(:user)
end
