class AddNotesToRecipes < ActiveRecord::Migration[7.1]
  def change
    add_column :recipes, :notes, :text
  end
end
