class User < ApplicationRecord
  authenticates_with_sorcery!

  has_many :recipes, dependent: :destroy
  has_many :recipe_books

  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }
end

