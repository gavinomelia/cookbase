require 'rails_helper'
require 'vcr'
require 'factory_bot_rails' 

RSpec.describe RecipeScraper, type: :service do
  let(:user) { create(:user) }

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
