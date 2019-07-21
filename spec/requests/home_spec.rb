require 'rails_helper'

RSpec.describe 'Home', type: :request do
  it 'works' do
    get root_path
    expect(response).to be_successful
  end

  specify "最新の3件を表示" do
    old_post = FactoryBot.create(:post)
    posts = FactoryBot.create_list(:post, 3)

    get root_path
    posts.each do |post|
      expect(response.body).to include post.title
    end
    expect(response.body).to_not include old_post.title
  end
end
