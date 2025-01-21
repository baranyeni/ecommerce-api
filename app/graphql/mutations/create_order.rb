module Mutations
  class CreateOrder < BaseMutation
    argument :customer_id, ID, required: true
    argument :cart_id, ID, required: true

    field :order, Types::OrderType, null: true
    field :errors, [String], null: false

    def resolve(customer_id:, cart_id:)
      customer = Customer.find_by(id: customer_id)
      return { errors: ['Customer not found'] } unless customer

      cart = customer.carts.active.find_by(id: cart_id)

      return { errors: ['Cart not found'] } unless cart
      return { errors: ['Cart is empty'] } if cart.cart_items.empty?

      result = Orders::CreateFromCart.new(cart).call

      if result.success?
        { order: result.data, errors: [] }
      else
        { order: nil, errors: [result.error] }
      end
    end
  end
end 