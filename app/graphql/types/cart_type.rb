module Types
  class CartType < Types::BaseObject
    field :id, ID, null: false
    field :customer, Types::CustomerType, null: false
    field :status, String, null: false
    field :cart_items, [Types::CartItemType], null: false
    field :subtotal, Float, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def cart_items
      object.cart_items.includes(:product)
    end

    def subtotal
      object.subtotal
    end
  end
end 