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
  puts "SCRAPE CALLED"
    url = params[:scrape_url]
    puts "URL = #{url}"
    return redirect_to new_recipe_path, alert: "URL can't be blank" if url.blank?

    html = fetch_html(url)
    doc = Nokogiri::HTML(html)
    json_contents = parse_json_ld(doc)
   # puts json_contents
    
      recipe_data = find_recipe_data(json_contents)
    #  puts "RECIPE DATA = #{recipe_data}"
      if recipe_data
        recipe_attrs = extract_recipe_attributes(recipe_data)

        @recipe = current_user.recipes.build(
          name: recipe_attrs[:name],
          directions: recipe_attrs[:directions],
          url: url
        )

       image_tempfile = attach_image(recipe_attrs[:image_url])

      recipe_attrs[:ingredients].each do |ingredient|
        @recipe.ingredients.build(name: ingredient)
      end

      puts "RECIPE DATA = #{recipe_data}"

      if @recipe.save
        image_tempfile.close
        image_tempfile.unlink

        redirect_to @recipe, notice: 'Recipe was successfully scraped and saved.'
      else
        image_tempfile.close
        image_tempfile.unlink if image_tempfile.present?

        render :new, alert: 'Failed to save the recipe.'
      end
      else
        redirect_to new_recipe_path, alert: "Failed to scrape recipe from URL."
      end
  end


private
    def extract_recipe_attributes(recipe_data)
      {
        name: recipe_data["name"],
        image_url: recipe_data["image"],
        ingredients: recipe_data["recipeIngredient"],
        directions: recipe_data["recipeInstructions"].map { |step| step["text"] }
      }
    end


    def find_recipe_data(json_contents)
      json_contents.each do |json_content|
     # puts "json content = #{json_content}"
        recipe_data = case json_content
        when Hash
        puts "HASH"
          if json_content["@graph"]
            json_content["@graph"].find { |item| item["@type"] == "Recipe" }
          elsif json_content["@type"] == "Recipe"
            json_content
          end
        when Array
        puts "ARRAY"
          json_content.find { |item| item["@type"].include?("Recipe") }
        end
        return recipe_data if recipe_data
      end
      nil
    end

    def fetch_html(url)
      URI.open(url).read
    end

    def attach_image(image_url)
      return if image_url.blank?

      image_url = image_url.first if image_url.is_a?(Array)
      image_url = image_url["url"] if image_url.is_a?(Hash)
      image_file = URI.parse(image_url).open
      extension = File.extname(URI.parse(image_url).path)
      file = Tempfile.new(['recipe_image', extension])

    begin
      file.binmode
      file.write(image_file.read)
      file.rewind

      @recipe.image.attach(io: file, filename: File.basename(image_url))
      
      file 
    end
    rescue => e
      Rails.logger.error "Failed to attach image: #{e.message}"
      file.unlink if file
    end

    def parse_json_ld(doc)
      json_ld_scripts = doc.css('script[type="application/ld+json"]')
      json_ld_scripts.map { |script| JSON.parse(script.text) }
    end

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

