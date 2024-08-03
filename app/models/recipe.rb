class Recipe < ApplicationRecord
  belongs_to :user
  has_many :ingredients, dependent: :destroy
  has_one_attached :image
  acts_as_taggable_on :tags
  accepts_nested_attributes_for :ingredients, allow_destroy: true

  validates :name, :directions, :user, presence: true

  validates :url, format: { with: URI::regexp(%w[http https]) }, allow_blank: true
has_one_attached :image

end
