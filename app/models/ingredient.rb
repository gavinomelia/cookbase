class Ingredient < ApplicationRecord
  belongs_to :recipe

  validates :name, presence: true
  before_save :extract_quantity

  private

  def extract_quantity
    # Matches fractions, integers, and decimals at the start of a string.
    regex = %r{\A(\d+\s+[¼½¾⅓⅔⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞]|\d+[/⁄∕⧸]\d+|\d+(\.\d+)?|[¼½¾⅓⅔⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞])}

    if match = self.name.strip.match(regex)
      self.quantity = floatify(match[0])
    else
      self.quantity = 1
    end
  end

  def floatify(str)
    # Handle mixed numbers like "2 ½" or "2 1/2" or "2½"
    if str.match?(/\d+\s?[¼½¾⅓⅔⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞]/) # Matches mixed numbers with vulgar fractions
      parts = str.split(/\s+/)
      whole_number = parts[0].to_i
      fraction_part = fraction_to_float(parts[1])
      return whole_number + fraction_part if fraction_part
    end

    # Handle fractions like "1/2" or "3/4"
    if str.match?(%r{\A\d+[/⁄∕⧸]\d+\z})
      numerator, denominator = str.split(%r{[/⁄∕⧸]}).map(&:to_f)
      return numerator / denominator
    end

    # If it's just a single fraction or number, convert it directly
    fraction_to_float(str) || str.to_f
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

