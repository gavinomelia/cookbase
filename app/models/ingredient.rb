class Ingredient < ApplicationRecord
  belongs_to :recipe

  validates :name, presence: true
  before_save :extract_quantity

  # Extracts quantity from the ingredient name
  def extract_quantity
    match = parse_quantity(name.strip)
    self.quantity = match || 1
  end

  private

  def parse_quantity(str)
    regex = %r{\A(\d+\s+[¼½¾⅓⅔⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞]|\d+[/⁄∕⧸]\d+|\d+(\.\d+)?|[¼½¾⅓⅔⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞])}

    return unless (match = str.match(regex))

    floatify(match[0])
  end

  def floatify(str)
    case str
    when /\d+\s?[¼½¾⅓⅔⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞]/ # Mixed numbers, e.g., "2 ½"
      parse_mixed_number(str)
    when %r{\A\d+[/⁄∕⧸]\d+\z} # Proper fractions, e.g., "3/4"
      parse_fraction(str)
    else
      fraction_to_float(str) || str.to_f # Vulgar fraction or regular number
    end
  end

  # Handles mixed numbers like "2 ½" or "2 1/2"
  def parse_mixed_number(str)
    parts = str.split(/\s+/)
    whole_number = parts[0].to_i
    fraction_part = fraction_to_float(parts[1]) || parse_fraction(parts[1])
    whole_number + (fraction_part || 0)
  end

  # Parses fractions like "3/4" or "1/2"
  def parse_fraction(str)
    numerator, denominator = str.split(%r{[/⁄∕⧸]}).map(&:to_f)
    numerator / denominator if denominator.nonzero?
  end

  # Converts a vulgar fraction (e.g., "½") into a float
  def fraction_to_float(str)
    {
      '¼' => 0.25, '½' => 0.5, '¾' => 0.75,
      '⅓' => 0.33, '⅔' => 0.66, '⅕' => 0.2,
      '⅖' => 0.4, '⅗' => 0.6, '⅘' => 0.8,
      '⅙' => 0.16, '⅚' => 0.83, '⅛' => 0.125,
      '⅜' => 0.375, '⅝' => 0.625, '⅞' => 0.875
    }[str]
  end
end

