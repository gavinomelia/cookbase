class RecipeBook < ApplicationRecord
  belongs_to :user
  has_many :recipes, dependent: :nullify
  validates :name, presence: true
end
