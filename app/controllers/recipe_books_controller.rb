class RecipeBooksController < ApplicationController
  before_action :require_login

  def index
    @recipe_books = current_user.recipe_books
  end

  def new
    @recipe_book = RecipeBook.new
  end

  def create
    @recipe_book = current_user.recipe_books.build(recipe_book_params)
    if @recipe_book.save
      redirect_to recipes_path, notice: "Recipe book created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def recipe_book_params
    params.require(:recipe_book).permit(:name)
  end
end
