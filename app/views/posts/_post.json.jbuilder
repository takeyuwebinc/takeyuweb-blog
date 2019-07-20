json.extract! post, :id, :title, :created_at, :updated_at
json.content post.content
json.url post_url(post, format: :json)
