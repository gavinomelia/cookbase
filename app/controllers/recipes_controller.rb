class RecipesController < ApplicationController

  before_action :require_login, except: [:index, :show]
  before_action :set_recipe, only: [:show, :edit, :update, :scale, :destroy]

  def index
    return redirect_to :login unless logged_in?

    @recipes = current_user.recipes.includes(image_attachment: :blob)
  end

  def search
    return redirect_to :login unless logged_in?

    @recipes = filtered_recipes

    respond_to do |format|
      format.turbo_stream # Handles Turbo request
      format.html { render :index } # Fallback for regular HTML requests
    end
  end

  def show
    @scaled_ingredients = []
  end

  def new
    @recipe = current_user.recipes.build
  end

  def edit; end

  def create
    @recipe = current_user.recipes.build(recipe_params)
    save_recipe(:new)
  end

  def update
    @recipe.update(recipe_params)
    save_recipe(:edit)
  end

  def destroy
    @recipe.destroy
    redirect_to root_path, notice: 'Recipe was successfully deleted.'
  end

  def scale
    scale_factor = params[:scale_factor].to_f
    @scaled_ingredients = @recipe.scale_ingredients(scale_factor)

    respond_to do |format|
      format.turbo_stream
    end
  end

  def scrape
    if params[:scrape_url].blank?
      redirect_to new_recipe_path, alert: "URL can't be blank"
      return
    end

    scraper = RecipeScraper.new(params[:scrape_url], current_user)
    if scraper.scrape
      redirect_to scraper.recipe, notice: 'Recipe was successfully scraped and saved.'
    else
      redirect_to new_recipe_path, alert: 'Failed to scrape recipe from URL.'
    end
  end

  private

  def save_recipe(action)
    if @recipe.save
      redirect_to @recipe, notice: 'Recipe was successfully saved.'
    else
      render action
    end
  end

  def filtered_recipes
    recipes = current_user.recipes
    recipes = recipes.tagged_with(selected_tags) if selected_tags.present?
    recipes = recipes.where("name ILIKE ?", "%#{params[:query]}%") if params[:query].present?
    recipes
  end

  def selected_tags
    params[:tags]&.reject(&:blank?)
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(:name, :directions, :image, :url, :notes, :tag_list, ingredients_attributes: %i[id name quantity scale _destroy])
  end

  def require_login
    return if logged_in?

    redirect_to login_path, alert: 'Please log in to view your recipes.'
  end
end
