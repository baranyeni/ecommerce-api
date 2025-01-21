module CartCalculations
  extend ActiveSupport::Concern

  def subtotal
    cart_items.includes(:product).sum { |item| item.quantity * item.product.price }
  end

  def tax_amount
    subtotal * 0.2
  end

  def total_price
    subtotal + tax_amount + shipping_cost
  end
end 