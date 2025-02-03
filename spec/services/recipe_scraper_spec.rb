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
