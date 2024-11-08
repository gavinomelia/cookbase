class Recipe < ApplicationRecord
  belongs_to :user
  has_many :ingredients, dependent: :destroy
  has_one_attached :image
  acts_as_taggable_on :tags
  accepts_nested_attributes_for :ingredients, allow_destroy: true

  validates :name, :directions, :user, presence: true
  validates :url, format: { with: URI::regexp(%w[http https]) }, allow_blank: true

  after_commit :preprocess_variants, on: [:create, :update], if: -> { image.attached? }

  private
  def preprocess_variants
    {
      thumbnail: image.variant(resize_to_fill: [200, 200]).processed,
      medium: image.variant(resize_to_fill: [400, 400]).processed
    }
  rescue ActiveStorage::FileNotFoundError => e
    Rails.logger.error("Image processing failed for Recipe ##{id}: #{e.message}")
    {}
  end
end

