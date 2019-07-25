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
        post = FactoryBot.create(:published_post)
        excluded = FactoryBot.create(:published_post, title: 'EXCLUDED')

        get '/posts', params: { query: post.title }
        expect(response).to have_http_status(200)
        expect(response.body).to include "post-#{post.id}"
        expect(response.body).to_not include "post-#{excluded.id}"
      end
    end

    describe '公開状態' do
      specify '未公開の記事は認証済みの場合のみ表示すること' do
        published_post = FactoryBot.create(:published_post)
        unpublished_post = FactoryBot.create(:unpublished_post)

        get '/posts'
        expect(response).to have_http_status(200)
        expect(response.body).to include "post-#{published_post.id}"
        expect(response.body).to_not include "post-#{unpublished_post.id}"

        name = SecureRandom.hex
        password = SecureRandom.hex
        Rails.application.credentials.basic_auth = {
          name: name, password: password
        }
        authorize_headers = {
          'Authorization' => "Basic #{Base64.encode64("#{name}:#{password}")}"
        }
        get '/posts', headers: authorize_headers
        expect(response).to have_http_status(200)
        expect(response.body).to include "post-#{published_post.id}"
        expect(response.body).to include "post-#{unpublished_post.id}"
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
          status: 'published',
          title: Faker::Lorem.word,
          content: "<p>#{Faker::Lorem.sentence}</p>"
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
    context '認証済みの場合' do
      specify '公開状態に関わらず表示できること' do
        name = SecureRandom.hex
        password = SecureRandom.hex
        Rails.application.credentials.basic_auth = {
          name: name, password: password
        }
        authorize_headers = {
          'Authorization' => "Basic #{Base64.encode64("#{name}:#{password}")}"
        }

        published_post = FactoryBot.create(:published_post)
        unpublished_post = FactoryBot.create(:unpublished_post)

        get "/posts/#{published_post.id}", headers: authorize_headers
        expect(response.body).to include published_post.title

        get "/posts/#{unpublished_post.id}", headers: authorize_headers
        expect(response).to have_http_status(:success)
        expect(response.body).to include unpublished_post.title
      end
    end

    context '認証しない場合' do
      specify '公開済みの記事のみ表示できること' do
        published_post = FactoryBot.create(:published_post)
        unpublished_post = FactoryBot.create(:unpublished_post)

        get "/posts/#{published_post.id}"
        expect(response).to have_http_status(:success)
        expect(response.body).to include published_post.title

        expect { get "/posts/#{unpublished_post.id}" }.to raise_error(
          ActiveRecord::RecordNotFound
        )
      end
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

      get "/posts/#{post.id}/edit",
          params: { id: post.id }, headers: invalid_headers
      expect(response).to have_http_status(:unauthorized)

      get "/posts/#{post.id}/edit",
          params: { id: post.id }, headers: valid_headers
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
        post: {
          status: 'published',
          title: Faker::Lorem.word,
          content: Faker::Lorem.sentence
        },
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
      expect(response.body).to include valid_params.dig(:postscript, :content)
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

      valid_params = { id: post.id }

      delete "/posts/#{post.id}", params: valid_params, headers: invalid_headers
      expect(response).to have_http_status(:unauthorized)

      delete "/posts/#{post.id}", params: valid_params, headers: valid_headers
      expect(response).to have_http_status(:redirect)

      expect(response).to redirect_to('/posts')

      follow_redirect!

      expect(response.body).to_not include "/posts/#{post.id}"
    end
  end
end
