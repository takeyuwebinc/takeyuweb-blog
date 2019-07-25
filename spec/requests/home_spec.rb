require 'rails_helper'

RSpec.describe 'Home', type: :request do
  it 'works' do
    get root_path
    expect(response).to be_successful
  end

  specify '最新の3件を表示' do
    old_post = FactoryBot.create(:published_post)
    posts = FactoryBot.create_list(:published_post, 3)

    get root_path
    posts.each { |post| expect(response.body).to include post.title }
    expect(response.body).to_not include old_post.title
  end

  context '認証済みでない場合' do
    specify '非公開は表示しない' do
      published_post = FactoryBot.create(:published_post)
      unpublished_post = FactoryBot.create(:unpublished_post)

      get root_path
      expect(response.body).to include published_post.title
      expect(response.body).to_not include unpublished_post.title
    end
  end

  context '認証済みの場合' do
    specify '非公開も表示する' do
      published_post = FactoryBot.create(:published_post)
      unpublished_post = FactoryBot.create(:unpublished_post)

      name = SecureRandom.hex
      password = SecureRandom.hex
      Rails.application.credentials.basic_auth = {
        name: name, password: password
      }
      authorize_headers = {
        'Authorization' => "Basic #{Base64.encode64("#{name}:#{password}")}"
      }

      get root_path, headers: authorize_headers
      expect(response.body).to include published_post.title
      expect(response.body).to include unpublished_post.title
    end
  end
end
