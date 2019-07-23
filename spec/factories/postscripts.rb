FactoryBot.define do
  factory :postscript do
    association :post
    content { Faker::Lorem.sentence }
  end
end
