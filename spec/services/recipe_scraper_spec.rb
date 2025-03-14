require 'rails_helper'
require 'vcr'
require 'factory_bot_rails' 

# Delete the VCR cassette for The Kitchn risotto to force re-recording
vcr_cassette_path = File.join(defined?(VCR) ? VCR.configuration.cassette_library_dir : 'spec/vcr_cassettes', 'the_kitchn_risotto.yml')

RSpec.describe RecipeScraper, type: :service do
  # Create a unique user for each test to prevent uniqueness validation errors
  let(:user) { create(:user, email: "user_#{rand(10000)}@example.com") }

  describe '#scrape' do
    context 'when the URL is valid and contains recipe data' do
      it 'successfully scrapes the recipe data' do
        VCR.use_cassette('valid_recipe_url') do
          scraper = RecipeScraper.new('https://www.allrecipes.com/recipe/99211/perfect-sushi-rice/', user)
          expect(scraper.scrape).to be_truthy
          expect(scraper.recipe).to be_present
          expect(scraper.error).to be_nil

          recipe = scraper.recipe
          expect(recipe[:name]).to eq('Perfect Sushi Rice')
          match_array([
            { name: 'uncooked glutinous white rice (sushi rice)', quantity: 2.0 },
            { name: 'water', quantity: 3.0 },
            { name: 'rice vinegar', quantity: 0.5 },
            { name: 'vegetable oil', quantity: 1.0 },
            { name: 'white sugar', quantity: 0.25 },
            { name: 'salt', quantity: 1.0 }
          ])
          expect(recipe[:directions]).to include(
            'Gather all ingredients.',
            'Rinse the rice in a strainer or colander under cold running water until the water runs clear.',
            'Combine rice and water in a saucepan over medium-high heat and bring to a boil. Reduce heat to low, cover, and cook until rice is tender and all water has been absorbed, about 20 minutes. Remove from stove and set aside until cool enough to handle.',
            'Meanwhile, combine rice vinegar, oil, sugar, and salt in a small saucepan over medium heat. Cook until the sugar has dissolved. Allow to cool. Then stir into the cooked rice. While mixture will appear very wet at first, keep stirring and rice will dry as it cools.',
            'Then stir into the cooked rice. While mixture will appear very wet at first, keep stirring and rice will dry as it cools.',
            'Enjoy!'
          )
          expect(recipe.image.attached?).to be_truthy
        end
      end
    end

    context 'when scraping a King Arthur Baking recipe' do
      it 'successfully scrapes the cheese ravioli recipe' do
        VCR.use_cassette('king_arthur_cheese_ravioli') do
          scraper = RecipeScraper.new('https://www.kingarthurbaking.com/recipes/homemade-cheese-ravioli-recipe', user)
          expect(scraper.scrape).to be_truthy
          expect(scraper.recipe).to be_present
          expect(scraper.error).to be_nil

          recipe = scraper.recipe
          expect(recipe.name).to eq('Homemade Cheese Ravioli')
          
          # Check ingredients
          ingredient_names = recipe.ingredients.map(&:name)
          expected_ingredients = [
            "2 cups (240g) King Arthur Unbleached All-Purpose Flour, plus more for sprinkling",
            "1/2 teaspoon table salt",
            "3 large eggs, at room temperature",
            "2 cups (454g) ricotta cheese",
            "1/4 cup (30g) King Arthur Unbleached All-Purpose Flour",
            "4 tablespoons (12g) fresh herbs, finely chopped*",
            "1/2 cup (50g) Parmesan cheese, grated",
            "1/4 cup (30g) Formaggio Italiano Cheese and Herb Blend*",
            "1/4 teaspoon pepper",
            "1/4 teaspoon table salt",
            "1/8 teaspoon nutmeg"
          ]
          
          expect(ingredient_names).to match_array(expected_ingredients)
          
          # Check directions are present and contain an expected instruction
          expect(recipe.directions).to be_present
          expect(recipe.directions).to include('To make the dough: Weigh your flour; or measure it by gently spooning it into a cup, then sweeping off any excess.')
          
          # Check image is attached
          expect(recipe.image.attached?).to be_truthy
        end
      end
    end

    context 'when scraping a A Couple Cooks recipe' do
      it 'successfully scrapes the nachos recipe' do
        VCR.use_cassette('a_couple_cooks_nachos') do
          scraper = RecipeScraper.new('https://www.acouplecooks.com/nachos-recipe/', user)
          expect(scraper.scrape).to be_truthy
          expect(scraper.recipe).to be_present
          expect(scraper.error).to be_nil

          recipe = scraper.recipe
          expect(recipe.name).to eq('Ultimate Nachos Recipe!')
          
          # Check ingredients
          ingredient_names = recipe.ingredients.map(&:name)
          expected_ingredients = [
            "1 1/2 cups Walnut Taco Meat or 1 pound ground beef",
            "1 15-ounce can refried beans",
            "1/2 cup salsa",
            "6 ounces organic corn chips (approximately 1 sheet pan)",
            "2 cups shredded Colby Jack or Mexican blend cheese (or Vegan Nacho Cheese, for vegan)",
            "1/2 cup pico de gallo (or finely diced tomato and red onion)",
            "1 tablespoon cilantro, chopped",
            "2 green onions, thinly sliced",
            "1 jalapeño pepper or 1/4 cup pickled jalapeños",
            "Sour cream, for garnish (omit for vegan and use cashew cream or nacho cheese)",
            "Guacamole, for garnish",
            "Optional toppings: Black olives, lettuce or corn"
          ]
          
          expect(ingredient_names).to match_array(expected_ingredients)
          
          # Check directions are present and contain expected instructions
          expect(recipe.directions).to be_present
          expect(recipe.directions).to include('Preheat the oven to 400 degrees Fahrenheit.')
          expect(recipe.directions).to include('Mix the refried beans with the salsa. Taste and add a few pinches kosher salt if desired.')
          
          # Check image is attached
          expect(recipe.image.attached?).to be_truthy
        end
      end
    end

    context 'when scraping a recipe from The Kitchn' do
      it 'successfully scrapes the sausage and tomato risotto recipe' do
        VCR.use_cassette('the_kitchn_risotto') do
          scraper = RecipeScraper.new('https://www.thekitchn.com/recipe-sausage-and-tomato-risotto-256197', user)
          expect(scraper.scrape).to be_truthy
          expect(scraper.recipe).to be_present
          expect(scraper.error).to be_nil

          recipe = scraper.recipe
          expect(recipe.name).to eq('Sausage and Tomato Risotto')
          
          # Check ingredients
          ingredient_names = recipe.ingredients.map(&:name)
          expected_ingredients = [
            "1  (28-ounce) can diced tomatoes",
            "4 cups (1 quart) low-sodium chicken or vegetable broth",
            "1 tablespoon olive oil",
            "1 pound uncooked sweet or hot Italian sausage, casings removed",
            "1 small yellow onion, diced ",
            "  Kosher salt",
            "  Freshly ground black pepper",
            "2 cups arborio, carnaroli, or vialone nano rice",
            "1/2 cup dry white wine",
            "1 cup finely grated Parmesan cheese, plus more for serving",
            "1 tablespoon unsalted butter",
            "1/2 cup loosely packed chopped fresh basil leaves"
          ]
          
          expect(ingredient_names).to match_array(expected_ingredients)
          
          # Check directions are present and contain expected instructions
          expect(recipe.directions).to be_present
          expect(recipe.directions).to include('Place the diced tomatoes and their juices and broth in a medium saucepan over low heat and keep it at a very low simmer.')
          expect(recipe.directions).to include('Remove the pan from the heat and stir in the Parmesan and butter until melted into the risotto. Stir in the reserved sausage and basil.')
          
          # Check image is attached
          expect(recipe.image.attached?).to be_truthy
        end
      end
    end

    context 'when the URL is invalid' do
      it 'returns an error' do
        VCR.use_cassette('invalid_recipe_url') do
          scraper = RecipeScraper.new('https://example.com/invalid_recipe', user)
          expect(scraper.scrape).to be_falsey
          expect(scraper.recipe).to be_nil
          expect(scraper.error).to eq('Could not fetch the recipe URL.')
        end
      end
    end
  end
end
