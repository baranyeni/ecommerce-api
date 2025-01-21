module Mutations
  class ManageCartItem < BaseMutation
    argument :customer_id, ID, required: true
    argument :product_id, ID, required: true
    argument :quantity, Int, required: true

    field :cart_item, Types::CartItemType, null: true
    field :cart, Types::CartType, null: true
    field :errors, [String], null: false

    def resolve(customer_id:, product_id:, quantity:)
      customer = Customer.find_by(id: customer_id)
      return { errors: ['Customer not found'] } unless customer

      product = Product.find_by(id: product_id)
      return { errors: ['Product not found'] } unless product
      return { errors: ['Requested quantity is not available'] } if quantity > product.stock_count

      cart = find_or_create_active_cart(customer)
      cart_item = find_or_initialize_cart_item(cart, product)
      
      if quantity.zero?
        cart_item.destroy
        {
          cart_item: nil,
          cart: cart.reload,
          errors: []
        }
      elsif cart_item.update(quantity: quantity)
        {
          cart_item: cart_item,
          cart: cart,
          errors: []
        }
      else
        {
          cart_item: nil,
          cart: nil,
          errors: cart_item.errors.full_messages
        }
      end
    end

    private

    def find_or_create_active_cart(customer)
      customer.carts.active.first || customer.carts.create!(status: :active)
    end

    def find_or_initialize_cart_item(cart, product)
      cart.cart_items.find_or_initialize_by(product: product)
    end
  end
end 