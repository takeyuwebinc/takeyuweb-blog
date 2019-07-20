require 'rails_helper'

RSpec.describe 'Posts', type: :request do
  describe 'GET /posts' do
    it 'works! (now write some real specs)' do
      get '/posts'
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /posts/new' do
    specify 'Basic認証が機能すること' do
      name = SecureRandom.hex
      password = SecureRandom.hex
      Rails.application.credentials.basic_auth = {
        name: name, password: password
      }

      invalid_headers = {
        'Authorization' => "Basic #{Base64.encode64('username:invalid')}"
      }

      valid_headers = {
        'Authorization' => "Basic #{Base64.encode64("#{name}:#{password}")}"
      }

      get '/posts/new'
      expect(response).to have_http_status(:unauthorized)

      get '/posts/new', headers: invalid_headers
      expect(response).to have_http_status(:unauthorized)

      get '/posts/new', headers: valid_headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /posts' do
    specify 'Basic認証が機能すること' do
      name = SecureRandom.hex
      password = SecureRandom.hex
      Rails.application.credentials.basic_auth = {
        name: name, password: password
      }

      invalid_headers = {
        'Authorization' => "Basic #{Base64.encode64('username:invalid')}"
      }

      valid_headers = {
        'Authorization' => "Basic #{Base64.encode64("#{name}:#{password}")}"
      }

      valid_attributes = { post: { title: 'TITLE', content: '<p>CONTENT</p>' } }

      post '/posts', params: valid_attributes
      expect(response).to have_http_status(:unauthorized)

      post '/posts', params: valid_attributes, headers: invalid_headers
      expect(response).to have_http_status(:unauthorized)

      post '/posts', params: valid_attributes, headers: valid_headers
      expect(response).to_not have_http_status(:unauthorized)
    end

    specify '投稿内容が反映されること' do
      name = SecureRandom.hex
      password = SecureRandom.hex
      Rails.application.credentials.basic_auth = {
        name: name, password: password
      }

      valid_headers = {
        'Authorization' => "Basic #{Base64.encode64("#{name}:#{password}")}"
      }
      valid_attributes = {
        post: {
          title: Faker::Lorem.word, content: "<p>#{Faker::Lorem.sentence}</p>"
        }
      }

      post '/posts', params: valid_attributes, headers: valid_headers
      expect(response).to redirect_to(%r{\/posts\/\d+})

      follow_redirect!

      expect(response.body).to include valid_attributes.dig(:post, :title)
      expect(response.body).to include valid_attributes.dig(:post, :content)
    end
  end

  describe 'GET /posts/:id' do
    it 'works!' do
      post = FactoryBot.create(:post)
      get "/posts/#{post.id}"
      expect(response).to have_http_status(200)
    end
  end
end
