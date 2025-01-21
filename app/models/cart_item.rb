# frozen_string_literal: true

class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }

  before_save :check_stock_availability

  private

  def check_stock_availability
    if quantity > product.stock_count
      errors.add(:quantity, 'is greater than available stock')
      throw(:abort)
    end
  end
end
