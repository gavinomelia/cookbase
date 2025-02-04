require 'open-uri'
require 'nokogiri'
require 'json'

class RecipeScraper
  attr_reader :recipe, :error

  def initialize(url, user, recipe_book_id = nil)
    @url = url
    @user = user
    @recipe_book_id = recipe_book_id
  end

  def scrape
    html = fetch_html
    return false unless html

    doc = Nokogiri::HTML(html)
    json_contents = parse_json_ld(doc)
    recipe_data = find_recipe_data(json_contents)

    if recipe_data
      process_recipe(recipe_data)
    else
      @error = "Failed to find recipe data."
      false
    end
  end

  private

  def fetch_html
    URI.open(@url).read
  rescue OpenURI::HTTPError => e
    Rails.logger.error "Failed to fetch URL: #{e.message}"
    @error = "Could not fetch the recipe URL."
    nil
  end

  def parse_json_ld(doc)
    json_ld_scripts = doc.css('script[type="application/ld+json"]')
    json_ld_scripts.map { |script| JSON.parse(script.text) }
  rescue JSON::ParserError => e
    Rails.logger.error "Failed to parse JSON-LD: #{e.message}"
    []
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

  def process_recipe(recipe_data)
    recipe_attrs = extract_recipe_attributes(recipe_data)
    normalized_image_url = normalize_image_url(recipe_attrs[:image_url])

    @recipe = @user.recipes.build(
      scraped_data: recipe_data,
      name: recipe_attrs[:name],
      directions: recipe_attrs[:directions],
      recipe_book_id: @recipe_book_id, 
      url: @url
    )

    tempfile = attach_image(normalized_image_url)
    build_ingredients(recipe_attrs[:ingredients])

    save_recipe(tempfile)
  end

  def extract_recipe_attributes(data)
    {
      name: data["name"],
      image_url: data["image"],
      directions: data["recipeInstructions"].map { |step| step["text"] },
      ingredients: data["recipeIngredient"]
    }
  end

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

  def attach_image(image_url)
    return unless image_url.present?

    tempfile = download_image(image_url)
    if tempfile
      @recipe.image.attach(io: tempfile, filename: File.basename(image_url))
    end
    tempfile
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

  def build_ingredients(ingredients)
    ingredients.each { |ingredient| @recipe.ingredients.build(name: ingredient) }
  end

  def save_recipe(tempfile)
    @recipe.save!
    tempfile&.close
    tempfile&.unlink
    true
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to save recipe: #{e.message}"
    @error = "Failed to save the recipe."
    false
  end
end
