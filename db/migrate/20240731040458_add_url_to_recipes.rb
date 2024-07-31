class AddUrlToRecipes < ActiveRecord::Migration[7.1]
  def change
    add_column :recipes, :url, :string
  end
end
