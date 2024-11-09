module IngredientsHelper
  def format_quantity(quantity)
    return "" if quantity.nil?

    if quantity.to_f == quantity.to_i
      quantity.to_i.to_s
    else
      quantity.round(2).to_s
    end
  end
end
