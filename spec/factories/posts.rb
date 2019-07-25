FactoryBot.define do
  factory :post do
    status { Post.statuses.keys.sample }
    sequence(:title) { |i| "[#{i}] #{Faker::Lorem.word}" }

    after(:build) do |post, evaluator|
      post.postscript = [FactoryBot.build(:postscript, post: nil), nil].sample
    end
  end

  factory :unpublished_post, parent: :post do
    status { "unpublished" }
  end

  factory :published_post, parent: :post do
    status { "published" }
  end
end
