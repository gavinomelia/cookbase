class AddScrapedDataToRecipes < ActiveRecord::Migration[7.1]
  def change
    add_column :recipes, :scraped_data, :jsonb
  end
end
