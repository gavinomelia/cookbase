class ChangeQuantityDefaultInIngredients < ActiveRecord::Migration[6.0]
  def change
    change_column_default :ingredients, :quantity, 1.0
  end
end

