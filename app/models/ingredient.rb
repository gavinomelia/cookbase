class Ingredient < ApplicationRecord
  belongs_to :recipe

  validates :name, presence: true
  before_save :extract_quantity

  private

  def extract_quantity
   # Matches fractions, integers, and decimals at the start of a string.
    regex = %r{\A(\d+/\d+|\d+(\.\d+)?)}

    if match = self.name.match(regex)
      self.quantity = match[0].to_f
     else self.quantity = 1
    end
  end
end
