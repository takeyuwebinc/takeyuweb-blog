FactoryBot.define do
  factory :post do
    title { Faker::Lorem.word }

    after(:build) do |post, evaluator|
      post.postscript = FactoryBot.build(:postscript, post: nil)
    end
  end
end
