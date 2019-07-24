class HomeController < ApplicationController
  def index
    @recent_posts = permitted_posts.recent.limit(3)
  end

  private

  def permitted_posts
    authenticated? ? Post.all : Post.published
  end
end
