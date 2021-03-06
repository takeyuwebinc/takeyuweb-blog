class PostsController < ApplicationController
  before_action :authenticate, except: %i[index show]
  before_action :set_post, only: %i[show edit update destroy]

  # GET /posts
  # GET /posts.json
  def index
    @posts = permitted_posts.page(params[:page]).per(10)
    @posts = @posts.search(params[:query]) if params[:query]

    @recent_posts = Post.recent.limit(3)
  end

  # GET /posts/1
  # GET /posts/1.json
  def show; end

  # GET /posts/new
  def new
    @post = Post.new
    @post.build_postscript
  end

  # GET /posts/1/edit
  def edit
    @post.build_postscript unless @post.postscript
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)
    @post.build_postscript(postscript_params)

    respond_to do |format|
      if @post.save
        format.html do
          redirect_to @post, notice: 'Post was successfully created.'
        end
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    postscript = @post.postscript || @post.build_postscript
    postscript.attributes = postscript_params

    respond_to do |format|
      if @post.update(post_params.merge(postscript: postscript))
        format.html do
          redirect_to @post, notice: 'Post was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html do
        redirect_to posts_url, notice: 'Post was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = permitted_posts.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def post_params
    params.require(:post).permit(:status, :title, :content)
  end

  def postscript_params
    params.require(:postscript).permit(:content)
  end

  def permitted_posts
    authenticated? ? Post.all : Post.published
  end
end
