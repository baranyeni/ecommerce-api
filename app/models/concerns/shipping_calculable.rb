module ShippingCalculable
  extend ActiveSupport::Concern

  included do
    SHIPPING_TIERS = {
      0..99.99 => 15.0,
      100..199.99 => 10.0,
      200..399.99 => 5.0,
      400..Float::INFINITY => 0.0
    }.freeze
  end

  def shipping_cost
    SHIPPING_TIERS.each do |range, cost|
      return cost if range.include?(subtotal)
    end
  end

  def free_shipping?
    shipping_cost.zero?
  end

  def next_shipping_tier
    SHIPPING_TIERS.each do |range, cost|
      if subtotal < range.begin
        return {
          current_cost: shipping_cost,
          next_cost: cost,
          amount_needed: (range.begin - subtotal).round(2)
        }
      end
    end
    nil
  end
end 