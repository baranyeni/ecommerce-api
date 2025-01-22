# frozen_string_literal: true

module Types
  class CustomerType < Types::BaseObject
    field :id, ID, null: false
    field :first_name, String, null: false
    field :last_name, String, null: false
    field :email, String, null: false
    field :phone_number, String, null: false
    field :password, String
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :active_cart, Types::CartType, null: true
    field :carts, [Types::CartType], null: false
    field :cart_items, [Types::CartItemType], null: false
    field :ongoing_orders, [Types::OrderType], null: false

    def active_cart
      object.carts.active.first
    end

    def cart_items
      active_cart&.cart_items || []
    end

    def ongoing_orders
      object.orders.ongoing
    end
  end
end
