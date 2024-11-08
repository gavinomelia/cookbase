class RecipesController < ApplicationController
  require 'open-uri'
  require 'nokogiri'
  require 'json'

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
    @scaled_ingredients = scaled_ingredients(scale_factor)

    respond_to do |format|
      format.turbo_stream
    end
  end

  def scrape
    return redirect_to new_recipe_path, alert: "URL can't be blank" if params[:scrape_url].blank?

    scrape_recipe(params[:scrape_url])
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

  def scaled_ingredients(scale_factor)
    @recipe.ingredients.map do |ingredient|
      {
        id: ingredient.id,
        name: ingredient.name,
        scaled_quantity: (ingredient.quantity || 1) * scale_factor
      }
    end
  end

  def scrape_recipe(url)
    html = fetch_html(url)
    doc = Nokogiri::HTML(html)
    json_contents = parse_json_ld(doc)
    recipe_data = find_recipe_data(json_contents)

    if recipe_data
      process_scraped_recipe(url, recipe_data)
    else
      redirect_to new_recipe_path, alert: 'Failed to scrape recipe from URL.'
    end
  end

  def process_scraped_recipe(url, recipe_data)
    recipe_attrs = extract_recipe_attributes(recipe_data)

    normalized_image_url = normalize_image_url(recipe_attrs[:image_url])

    @recipe = current_user.recipes.build(
      scraped_data: recipe_data,
      name: recipe_attrs[:name],
      directions: recipe_attrs[:directions],
      url: url
    )

    tempfile = attach_image(normalized_image_url)
    build_ingredients(recipe_attrs[:ingredients])

    save_scraped_recipe(tempfile)
  end

  def build_ingredients(ingredients)
    ingredients.each { |ingredient| @recipe.ingredients.build(name: ingredient) }
  end

  def save_scraped_recipe(tempfile)
    if @recipe.save
      redirect_to @recipe, notice: 'Recipe was successfully scraped and saved.'
    else
      render :new, alert: 'Failed to save the recipe.'
    end
  ensure
    tempfile&.close
    tempfile&.unlink
  end


  def fetch_html(url)
    URI.open(url).read
  rescue OpenURI::HTTPError => e
    Rails.logger.error "Failed to fetch URL: #{e.message}"
    redirect_to new_recipe_path, alert: 'Could not fetch the recipe URL.'
  end

  def attach_image(image_url)
    return unless image_url.present?

    tempfile = download_image(image_url)
    if tempfile
      @recipe.image.attach(io: tempfile, filename: File.basename(image_url))
    end
    tempfile 
  end


  private

  def normalize_image_url(image_url)
    case image_url
    when Array
      image_url.first
    when Hash
      image_url["url"]
    when String
      image_url
    else
      nil
    end
  end

  def download_image(image_url)
    image_file = URI.parse(image_url).open
    extension = File.extname(URI.parse(image_url).path)
    file = Tempfile.new(['recipe_image', extension])
    file.binmode
    file.write(image_file.read)
    file.rewind
    file
  rescue OpenURI::HTTPError, URI::InvalidURIError => e
    Rails.logger.error "Failed to download image: #{e.message}"
    nil
  end


  def parse_json_ld(doc)
    json_ld_scripts = doc.css('script[type="application/ld+json"]')
    json_ld_scripts.map { |script| JSON.parse(script.text) }
  end

  def find_recipe_data(json_contents)
    json_contents.each do |content|
      recipe_data = extract_recipe_data(content)
      return recipe_data if recipe_data
    end
    nil
  end

  def extract_recipe_data(content)
    if content.is_a?(Hash) && content["@graph"]
      return content["@graph"].find { |item| item["@type"].include?("Recipe") }
    end

    return content if content.is_a?(Hash) && content["@type"].include?("Recipe")

    return content.find { |item| item["@type"].include?("Recipe") } if content.is_a?(Array)
  end

  def extract_recipe_attributes(data)
    {
      name: data["name"],
      image_url: data["image"],
      ingredients: data["recipeIngredient"],
      directions: data["recipeInstructions"].map { |step| step["text"] }
    }
  end

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
