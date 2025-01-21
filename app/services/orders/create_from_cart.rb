# frozen_string_literal: true

require 'ostruct'

module Orders
  class CreateFromCart
    def initialize(cart)
      @cart = cart
      @order = nil
    end

    def call
      return failure("Cart is empty") if @cart.cart_items.empty?
      return failure("Some products are out of stock") unless stock_available?

      ActiveRecord::Base.transaction do
        @cart.move_to_processing!
        @order = create_order_with_items
        return failure("Cannot process payment") unless @order.can_move_to_in_payment?

        process_payment
        reserve_stocks

        @cart.move_to_completed!
        success(@order)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure(e.message)
    rescue => e
      failure(e.message)
    end

    private

    def process_payment
      Payments::ProcessPayment.new(order: @order).call
    end

    def stock_available?
      @cart.cart_items.all? do |item|
        item.product.available_for_quantity?(item.quantity)
      end
    end

    def create_order_with_items
      order_items_attributes = @cart.cart_items.map do |cart_item|
        { product_id: cart_item.product_id, quantity: cart_item.quantity }
      end

      Order.create!(
        customer: @cart.customer,
        status: :active,
        order_items_attributes: order_items_attributes,
        total_price: @cart.cart_items.sum { |ci| ci.quantity * ci.product.price }
      )
    end

    def reserve_stocks
      @cart.cart_items.each do |item|
        item.product.reserve_stock(item.quantity)
      end
    end

    def success(order)
      ServiceResult.new(success: true, data: order)
    end

    def failure(message)
      @cart.move_to_active!

      ServiceResult.new(success: false, error: message)
    end
  end
end 