class Ingredient < ApplicationRecord
  belongs_to :recipe

  validates :name, presence: true
  before_save :extract_quantity

  private

  def extract_quantity
   # Matches fractions, integers, and decimals at the start of a string.
    regex = %r{\A(\d+/\d+|\d+(\.\d+)?|[¼½¾⅓⅔⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞])}

    if match = self.name.match(regex)
      floatify(match[0])
    else 
      self.quantity = 1
    end
  end

  def floatify(str)
    if fraction_to_float(str) != nil
      self.quantity = fraction_to_float(str)
    else
      self.quantity = str.to_f
    end
  end

  def fraction_to_float(str)
    conversion = {
      '¼' => 0.25,
      '½' => 0.5,
      '¾' => 0.75,
      '⅓' => Rational(1, 3).to_f.round(2),
      '⅔' => Rational(2, 3).to_f.round(2),
      '⅕' => 0.2,
      '⅖' => 0.4,
      '⅗' => 0.6,
      '⅘' => 0.8,
      '⅙' => Rational(1, 6).to_f.round(2),
      '⅚' => Rational(5, 6).to_f.round(2),
      '⅛' => 0.125,
      '⅜' => 0.375,
      '⅝' => 0.625,
      '⅞' => 0.875
    }

    conversion[str]
  end

end
