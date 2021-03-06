class ArticlesController < ApplicationController
  before_action :set_article, only: [:show,  :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :verify_user!, only: [:edit, :update, :destroy]
  before_action :hide_unapproved, only: [:show]

  # GET /articles
  # GET /articles.json
  def index
    if params[:tag]
      @articles = Article.approved.tagged_with(params[:tag]).page params[:page]
    # elsif params[:search]
    #   @articles = Article.search(params[:search], with: {approved: true, fresh: false}, order: 'approved_at DESC', include: [:user, :categories]).page params[:page]
    #   @articles.context[:panes] << ThinkingSphinx::Panes::ExcerptsPane
    else 
      @articles = Article.approved.page params[:page]
    end
  end

  # GET /articles/1
  # GET /articles/1.json
  def show
    @comments = @article.root_comments.includes(:user, :children).order('created_at desc')
    @new_comment = Comment.build_from(@article, current_user, "", "")
  end

  # GET /articles/new
  def new
    @article = Article.new
  end

  # GET /articles/1/edit
  def edit
  end

  # POST /articles
  # POST /articles.json
  def create
    @article = Article.new(article_params)
    @article.user = current_user
    respond_to do |format|
  
      if params[:preview_button] || !@article.save 
        format.html { render action: 'new' }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      else
        format.html { redirect_to @article, notice: t('articles.successfully_created') }
        format.json { render action: 'show', status: :created, location: @article }
      end
    end
  end

  # PATCH/PUT /articles/1
  # PATCH/PUT /articles/1.json
  def update
    respond_to do |format|
      # Require remoderation after update
      full_article_params = article_params.merge(fresh: true)
      if !@article.update(full_article_params) 
        format.html { render action: 'edit' }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      else
        format.html { redirect_to @article, notice: t('articles.successfully_updated') }
        format.json { head :no_content }
      end
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.json
  def destroy
    @article.destroy
    respond_to do |format|
      format.html { redirect_to articles_url, notice: t('articles.successfully_deleted') }
      format.json {render json: {model: "article", id: @article.id }, status: :ok}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def article_params
      params.require(:article).permit(:title, :summary, :body, :tag_list, category_ids: [])
    end

    def redirect_with_error
      redirect_to articles_path, error: t('articles.not_allowed')
    end

    # Verify that current user is owner or admin
    def verify_user!
      redirect_with_error  unless current_user.try(:admin?) || @article.user == current_user
    end

    # Show unapproved articles only for owner and admin
    def hide_unapproved
      unless @article.approved?
        redirect_with_error
      end
    end

end
