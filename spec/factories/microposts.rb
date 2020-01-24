FactoryBot.define do
  factory :micropost do
    content { Faker::Lorem.paragraph(sentence_count: 3) }
  end
end
