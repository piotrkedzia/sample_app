FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'start123' }
    password_confirmation { 'start123' }
    activated { true }
    activated_at { Time.zone.now }

    factory :user_with_microposts do
      transient do
        microposts_count { 5 }
      end

      after(:create) do |user, evaluator|
        create_list(:micropost, evaluator.microposts_count, user: user)
      end
    end
  end
end