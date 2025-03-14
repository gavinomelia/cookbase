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
    user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36'
    
    # Use options hash with headers to set User-Agent
    URI.open(uri, 
      "User-Agent" => user_agent,
      "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
      "Accept-Language" => "en-US,en;q=0.5"
    ).read
  rescue URI::InvalidURIError, Errno::ENOENT => e
    Rails.logger.error "Invalid URL format: #{e.message}"
    @error = "Invalid URL format. Please provide a valid HTTP or HTTPS URL."
    nil
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
    Rails.logger.error "No recipe data found in JSON-LD content"
    nil
  end

  def extract_recipe_data(content)
    # Debug log to understand content structure
    Rails.logger.debug "JSON-LD Content type: #{content.class}, keys: #{content.keys}" if content.is_a?(Hash)
    
    if content.is_a?(Hash) && content["@graph"]
      # Find any Recipe objects in the graph
      recipe = content["@graph"].find { |item| 
        item.is_a?(Hash) && (item["@type"] == "Recipe" || (item["@type"].is_a?(Array) && item["@type"].include?("Recipe")))
      }
      return recipe if recipe
    end

    # Direct Recipe object
    if content.is_a?(Hash) && (content["@type"] == "Recipe" || (content["@type"].is_a?(Array) && content["@type"].include?("Recipe")))
      return content
    end

    # Array of items, find Recipe
    if content.is_a?(Array)
      recipe = content.find { |item| 
        item.is_a?(Hash) && (item["@type"] == "Recipe" || (item["@type"].is_a?(Array) && item["@type"].include?("Recipe")))
      }
      return recipe if recipe
    end

    nil
  end

  def process_recipe(recipe_data)
    begin
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
      Rails.logger.error "Error processing recipe: #{e.message}\n#{e.backtrace.join("\n")}"
      @error = "Failed to process the recipe: #{e.message}"
      false
    end
  end

  def extract_recipe_attributes(data)
    Rails.logger.debug "Recipe data keys: #{data.keys}"
    Rails.logger.debug "Recipe instructions type: #{data["recipeInstructions"].class} #{data["recipeInstructions"].first.class if data["recipeInstructions"].is_a?(Array)}"
    
    directions = if data["recipeInstructions"].is_a?(Array)
                  if data["recipeInstructions"].first.is_a?(Hash)
                    if data["recipeInstructions"].first["@type"] == "HowToStep" || data["recipeInstructions"].first["@type"] == "HowToSection"
                      if data["recipeInstructions"].first["@type"] == "HowToSection"
                        # Extract steps from HowToSection objects that have itemListElement arrays
                        sections_steps = data["recipeInstructions"].flat_map do |section|
                          if section["itemListElement"].is_a?(Array)
                            section["itemListElement"].map { |step| step["text"] }
                          else
                            []
                          end
                        end
                        sections_steps
                      else
                        # Standard HowToStep objects
                        data["recipeInstructions"].map { |step| step["text"] }
                      end
                    elsif data["recipeInstructions"].first.key?("text")
                      # Extract text from objects with text property
                      data["recipeInstructions"].map { |step| step["text"] }
                    else
                      # Plain array of steps
                      data["recipeInstructions"]
                    end
                  else
                    # Plain array of strings
                    data["recipeInstructions"]
                  end
                elsif data["recipeInstructions"].is_a?(String)
                  # Single string - split by periods or newlines for better formatting
                  data["recipeInstructions"].split(/\.\s+|\n+/).map(&:strip).reject(&:empty?)
                else
                  # Anything else, convert to string and put in array
                  [data["recipeInstructions"].to_s]
                end
    
    # Ensure directions is always an array, even if empty
    directions = [] if directions.nil?
    # Handle nested arrays (flatten to single level)
    directions = directions.flatten if directions.is_a?(Array) && directions.any? { |d| d.is_a?(Array) }
    # Remove any nil entries
    directions = directions.compact if directions.is_a?(Array)

    # Add debug logging
    Rails.logger.debug "Extracted directions: #{directions.inspect}"

    {
      name: data["name"],
      image_url: data["image"],
      directions: directions,
      ingredients: data["recipeIngredient"]
    }
  end

  def normalize_image_url(image_url)
    case image_url
    when Array
      # Handle cases where image is an array of objects with url property
      if image_url.first.is_a?(Hash) && image_url.first["url"]
        image_url.first["url"]
      else
        image_url.first
      end
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
    # Also use browser-like headers when downloading images
    user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36'
    
    image_file = URI.parse(image_url).open(
      "User-Agent" => user_agent,
      "Accept" => "image/avif,image/webp,*/*"
    )
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
