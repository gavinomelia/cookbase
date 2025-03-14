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
    uri = URI.parse(@url)
    raise URI::InvalidURIError unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    
    # Add a realistic User-Agent to avoid 403 Forbidden errors
    user_agent = browser_user_agent
    
    # Use options hash with headers to set User-Agent
    URI.open(uri, 
      "User-Agent" => user_agent,
      "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
      "Accept-Language" => "en-US,en;q=0.5"
    ).read
  rescue URI::InvalidURIError, Errno::ENOENT => e
    log_error("Invalid URL format", e)
    @error = "Invalid URL format. Please provide a valid HTTP or HTTPS URL."
    nil
  rescue OpenURI::HTTPError => e
    log_error("Failed to fetch URL", e)
    @error = "Could not fetch the recipe URL."
    nil
  end

  def browser_user_agent
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36'
  end

  def parse_json_ld(doc)
    json_ld_scripts = doc.css('script[type="application/ld+json"]')
    json_ld_scripts.map { |script| JSON.parse(script.text) }
  rescue JSON::ParserError => e
    log_error("Failed to parse JSON-LD", e)
    []
  end

  def find_recipe_data(json_contents)
    json_contents.each do |content|
      recipe_data = extract_recipe_data(content)
      return recipe_data if recipe_data
    end
    
    log_error("No recipe data found in JSON-LD content", nil)
    nil
  end

  def extract_recipe_data(content)
    return nil unless content.is_a?(Hash) || content.is_a?(Array)
    
    # Case 1: Recipe in @graph array
    if content.is_a?(Hash) && content["@graph"].is_a?(Array)
      recipe = find_recipe_in_array(content["@graph"])
      return recipe if recipe
    end

    # Case 2: Direct Recipe object
    if content.is_a?(Hash) && is_recipe_object?(content)
      return content
    end

    # Case 3: Recipe in array
    if content.is_a?(Array)
      recipe = find_recipe_in_array(content)
      return recipe if recipe
    end

    nil
  end

  def is_recipe_object?(item)
    return false unless item.is_a?(Hash)
    
    if item["@type"].is_a?(String)
      return item["@type"] == "Recipe"
    elsif item["@type"].is_a?(Array)
      return item["@type"].include?("Recipe")
    end
    
    false
  end

  def find_recipe_in_array(array)
    array.find { |item| is_recipe_object?(item) }
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
  rescue => e
    log_error("Error processing recipe", e)
    @error = "Failed to process the recipe: #{e.message}"
    false
  end

  def extract_recipe_attributes(data)
    log_debug("Recipe data keys", data.keys)
    
    directions = extract_directions(data["recipeInstructions"])
    
    {
      name: data["name"],
      image_url: data["image"],
      directions: directions,
      ingredients: data["recipeIngredient"]
    }
  end

  def extract_directions(instructions)
    return [] if instructions.nil?
    
    directions = case instructions
                 when Array
                   extract_directions_from_array(instructions)
                 when String
                   split_string_into_directions(instructions)
                 else
                   [instructions.to_s]
                 end
    
    # Ensure we have a flattened array without nil entries
    directions = directions.flatten.compact
    
    log_debug("Extracted directions", directions)
    directions
  end

  def extract_directions_from_array(instructions)
    return [] if instructions.empty?
    
    if instructions.first.is_a?(Hash)
      extract_directions_from_hash_array(instructions)
    else
      # It's an array of strings
      instructions
    end
  end

  def extract_directions_from_hash_array(instructions)
    # Handle HowToSection objects (contains itemListElement arrays)
    if instructions.first["@type"] == "HowToSection"
      instructions.flat_map do |section|
        if section["itemListElement"].is_a?(Array)
          section["itemListElement"].map { |step| step["text"] }
        else
          []
        end
      end
    # Handle HowToStep objects or objects with text property
    elsif instructions.first["@type"] == "HowToStep" || instructions.first.key?("text")
      instructions.map { |step| step["text"] }
    else
      # Fallback for any other array structure
      instructions
    end
  end

  def split_string_into_directions(text)
    text.split(/\.\s+|\n+/).map(&:strip).reject(&:empty?)
  end

  def normalize_image_url(image_url)
    case image_url
    when Array
      # Array of images - take the first one
      if image_url.first.is_a?(Hash) && image_url.first["url"]
        image_url.first["url"]
      else
        image_url.first
      end
    when Hash
      # Image object with url property
      image_url["url"]
    when String
      # Direct image URL
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
    image_file = URI.parse(image_url).open(
      "User-Agent" => browser_user_agent,
      "Accept" => "image/avif,image/webp,*/*"
    )
    extension = File.extname(URI.parse(image_url).path)
    file = Tempfile.new(['recipe_image', extension])
    file.binmode
    file.write(image_file.read)
    file.rewind
    file
  rescue OpenURI::HTTPError, URI::InvalidURIError => e
    log_error("Failed to download image", e)
    nil
  end

  def build_ingredients(ingredients)
    return unless ingredients.is_a?(Array)
    ingredients.each { |ingredient| @recipe.ingredients.build(name: ingredient) }
  end

  def save_recipe(tempfile)
    @recipe.save!
    tempfile&.close
    tempfile&.unlink
    true
  rescue ActiveRecord::RecordInvalid => e
    log_error("Failed to save recipe", e)
    @error = "Failed to save the recipe."
    false
  end

  def log_error(message, error)
    error_message = error ? "#{message}: #{error.message}" : message
    Rails.logger.error(error_message)
    Rails.logger.error(error.backtrace.join("\n")) if error&.backtrace
  end

  def log_debug(message, data)
    Rails.logger.debug("#{message}: #{data.inspect}")
  end
end
