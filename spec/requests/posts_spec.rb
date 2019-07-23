require 'rails_helper'

RSpec.describe 'Posts', type: :request do
  describe 'GET /posts' do
    it 'works! (now write some real specs)' do
      FactoryBot.create_list(:post, rand(20))

      get '/posts'
      expect(response).to have_http_status(200)
    end

    describe '検索' do
      example do
        post = FactoryBot.create(:post)
        excluded = FactoryBot.create(:post, title: 'EXCLUDED')

        get '/posts', params: { query: post.title }
        expect(response).to have_http_status(200)
        expect(response.body).to include "post-#{post.id}"
        expect(response.body).to_not include "post-#{excluded.id}"
      end
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

      valid_attributes = {
        post: { title: Faker::Lorem.word, content: Faker::Lorem.sentence },
        postscript: { content: Faker::Lorem.sentence }
      }

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
        },
        postscript: { content: Faker::Lorem.sentence }
      }

      post '/posts', params: valid_attributes, headers: valid_headers
      expect(response).to redirect_to(%r{\/posts\/\d+})

      follow_redirect!

      expect(response.body).to include valid_attributes.dig(:post, :title)
      expect(response.body).to include valid_attributes.dig(:post, :content)
      expect(response.body).to include valid_attributes.dig(
                :postscript,
                :content
              )
    end
  end

  describe 'GET /posts/:id' do
    it 'works!' do
      post = FactoryBot.create(:post)
      get "/posts/#{post.id}"
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /posts/:id/edit' do
    it 'works!' do
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

      post = FactoryBot.create(:post)

      get "/posts/#{post.id}/edit", params: { id: post.id }, headers: invalid_headers
      expect(response).to have_http_status(:unauthorized)

      get "/posts/#{post.id}/edit", params: { id: post.id }, headers: valid_headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PUT /posts/:id' do
    it 'works!' do
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

      post = FactoryBot.create(:post)

      valid_params = {
        id: post.id,
        post: { title: Faker::Lorem.word, content: Faker::Lorem.sentence },
        postscript: { content: Faker::Lorem.sentence }
      }

      put "/posts/#{post.id}", params: valid_params, headers: invalid_headers
      expect(response).to have_http_status(:unauthorized)

      put "/posts/#{post.id}", params: valid_params, headers: valid_headers
      expect(response).to have_http_status(:redirect)

      expect(response).to redirect_to("/posts/#{post.id}")

      follow_redirect!

      expect(response.body).to include valid_params.dig(:post, :title)
      expect(response.body).to include valid_params.dig(:post, :content)
      expect(response.body).to include valid_params.dig(
                :postscript,
                :content
              )
    end
  end

  describe 'DELETE /posts/:id' do
    it 'works!' do
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

      post = FactoryBot.create(:post)

      valid_params = {
        id: post.id
      }

      delete "/posts/#{post.id}", params: valid_params, headers: invalid_headers
      expect(response).to have_http_status(:unauthorized)

      delete "/posts/#{post.id}", params: valid_params, headers: valid_headers
      expect(response).to have_http_status(:redirect)

      expect(response).to redirect_to("/posts")

      follow_redirect!

      expect(response.body).to_not include "/posts/#{post.id}"
    end
  end
end
