class AddRecipeBookToRecipes < ActiveRecord::Migration[7.0]
  def change
    add_reference :recipes, :recipe_book, foreign_key: true, null: true
  end
end
