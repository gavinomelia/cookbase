module RecipesHelper
  def recipe_image(recipe)
    if recipe.image.attached? && recipe.image.representable?
      recipe.image.variant(resize_to_fill: [400, 400]).processed
    else
      'recipe_icon.png'
    end
  rescue ActiveStorage::FileNotFoundError
    'recipe_icon.png'
  end
end
