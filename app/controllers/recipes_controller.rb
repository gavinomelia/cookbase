class RecipesController < ApplicationController
require 'open-uri'
require 'nokogiri'
require 'json'

  before_action :require_login, except: [:index, :show]
  before_action :set_recipe, only: [:show, :edit, :update, :scale, :destroy]

  # GET /recipes
  def index
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



  def scrape
    url = params[:scrape_url]
    return redirect_to new_recipe_path, alert: "URL can't be blank" if url.blank?
    html = URI.open(url).read
    doc = Nokogiri::HTML(html)

    json_ld_scripts = doc.css('script[type="application/ld+json"]') 

  json_ld_scripts.each do |script|
    json_content = JSON.parse(script.text)
    
  recipe_data = case json_content
  when Hash
    if json_content["@graph"]
      json_content["@graph"].find { |item| item["@type"] == "Recipe" }
    elsif json_content["@type"] == "Recipe" 
      json_content
    end
  when Array
    json_content.find { |item| item["@type"] == "Recipe" || ["Recipe"]}
  end

  if recipe_data
    recipe = {
    name: recipe_data["name"],
    ingredients: recipe_data["recipeIngredient"],
    directions: recipe_data["recipeInstructions"].map { |step| step["text"] }
    }

        name = recipe[:name]
        directions = recipe[:directions]
        ingredients = recipe[:ingredients]

      @recipe = current_user.recipes.build(name: name, directions: directions, url: url)
  
      ingredients.each do |ingredient|
        @recipe.ingredients.build(name: ingredient)
      end

      if @recipe.save
        return redirect_to @recipe, notice: 'Recipe was successfully scraped and saved.'
      else
        render :new
      end
  else
     return redirect_to new_recipe_path, alert: "Failed to scrape the recipe. Please check the URL and try again. You may need to enter the recipe manually."

  end
    end
  end

private

    def set_recipe
      @recipe = Recipe.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def recipe_params
      params.require(:recipe).permit(:name, :directions, :image, :url, :notes, :tag_list, ingredients_attributes: [:id, :name, :quantity, :scale, :_destroy])
    end

    # Ensure user is logged in before accessing recipes
    def require_login
      unless logged_in?
        redirect_to login_path, alert: "Please log in to view your recipes."
      end
    end
end

