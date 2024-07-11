class RecipesController < ApplicationController
  before_action :require_login, except: [:index, :show]
  before_action :set_recipe, only: [:show, :edit, :update, :scale, :destroy]

  # GET /recipes
  def index
   # @recipes = []
     if logged_in?
      @recipes = current_user.recipes
    end
  end

  def show
    @scaled_ingredients = []
  end

  def new
    @recipe = current_user.recipes.build
  end

  def edit
  end

  def create
   @recipe = current_user.recipes.build(recipe_params)

   if @recipe.save
      redirect_to @recipe, notice: 'Recipe was successfully created.'
    else
       render :new
    end
  end

  def update
    if @recipe.update(recipe_params)
      redirect_to @recipe, notice: 'Recipe was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @recipe.destroy

    redirect_to root_path
  end

  
  def scale
    scale_factor = params[:scale_factor].to_f
    @scaled_ingredients = @recipe.ingredients.map do |ingredient|
      {
        id: ingredient.id,
        name: ingredient.name,
        scaled_quantity: (ingredient.quantity || 1) * scale_factor
      }
    end

    respond_to do |format|
      format.turbo_stream
    end
  end
 
private

    def set_recipe
      @recipe = Recipe.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def recipe_params
      params.require(:recipe).permit(:name, :directions, ingredients_attributes: [:id, :name, :quantity, :scale, :_destroy])
    end

    # Ensure user is logged in before accessing recipes
    def require_login
      unless logged_in?
        redirect_to login_path, alert: "Please log in to view your recipes."
      end
    end
end

