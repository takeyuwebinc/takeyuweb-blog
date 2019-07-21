class HomeController < ApplicationController
  def index
    @recent_posts = Post.recent.limit(3)
  end
end
