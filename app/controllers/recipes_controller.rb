class RecipesController < ApplicationController
require 'open-uri'
require 'nokogiri'

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

    begin
      html = URI.open(url)
      doc = Nokogiri::HTML(html)

      ingredients = extract_ingredients(doc)
      directions = extract_directions(doc)

      name = doc.at_css('h1').text.strip rescue "Untitled Recipe"

      @recipe = current_user.recipes.build(name: name, directions: directions)

      ingredients.each do |ingredient|
        @recipe.ingredients.build(name: ingredient)
        puts "Ingredient: #{ingredient}"
      end

      if @recipe.save
        redirect_to @recipe, notice: 'Recipe was successfully scraped and saved.'
      else
        render :new
      end
    rescue => e
      redirect_to new_recipe_path, alert: "Failed to scrape the recipe. Please check the URL and try again. Error: #{e.message}"
    end
  end

private

    def extract_ingredients(doc)
      ingredient_selectors = [
        '#mm-recipes-structured-ingredients_1-0 .mm-recipes-structured-ingredients__list-item',
        '.recipe-ingredients__list-item',
        '.ingredient-list-item'
      ]

      ingredient_selectors.each do |selector|
        ingredients = doc.css(selector).map do |item|
          quantity = item.at_css('span[data-ingredient-quantity]').text.strip rescue nil
          unit = item.at_css('span[data-ingredient-unit]').text.strip rescue nil
          name = item.at_css('span[data-ingredient-name]').text.strip rescue nil
          "#{quantity} #{unit} #{name}".strip if name
        end.compact
        return ingredients unless ingredients.empty?
      end

      []
    end

    def extract_directions(doc)
      direction_selectors = [
        '#mntl-sc-block_1-0 li', 
        '#mntl-sc-block_3-0 li',
        '.recipe-directions__list--item',
       '.mntl-sc-block-group--LI',
      ]

      direction_selectors.each do |selector|
        directions = doc.css(selector).map do |step|
          step.at_css('p').text.strip rescue step.text.strip
        end.join("\n")
        return directions unless directions.empty?
      end

      ""
    end

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

