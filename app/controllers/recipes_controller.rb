class RecipesController < ApplicationController
  before_action :require_login, except: [:index, :show]
  before_action :set_recipe, only: [:show, :edit, :update, :destroy]

  # GET /recipes
  def index
     if logged_in?
      @recipes = current_user.recipes
    end
  end

  # GET /recipes/1
  def show
    # @recipe is set in set_recipe before_action
  end

  # GET /recipes/new
  def new
    @recipe = current_user.recipes.build
  end

  # GET /recipes/1/edit
  def edit
    # @recipe is set in set_recipe before_action
  end

  # POST /recipes
  def create
    @recipe = current_user.recipes.build(recipe_params)

    if @recipe.save
      redirect_to @recipe, notice: 'Recipe was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /recipes/1
  def update
    # @recipe is set in set_recipe before_action

    if @recipe.update(recipe_params)
      redirect_to @recipe, notice: 'Recipe was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /recipes/1
  def destroy
    # @recipe is set in set_recipe before_action
    @recipe.destroy
    redirect_to recipes_url, notice: 'Recipe was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recipe
      @recipe = current_user.recipes.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def recipe_params
      params.require(:recipe).permit(:name, :ingredients, :directions, :image)
    end

    # Ensure user is logged in before accessing recipes
    def require_login
      unless logged_in?
        redirect_to login_path, alert: "Please log in to view your recipes."
      end
    end
end

