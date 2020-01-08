FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'start123' }
    password_confirmation { 'start123' }
  end
end