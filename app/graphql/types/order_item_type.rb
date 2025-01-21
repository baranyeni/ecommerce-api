module Types
  class OrderItemType < Types::BaseObject
    field :id, ID, null: false
    field :order_id, ID, null: false
    field :order, Types::OrderType, null: false
    field :product_id, ID, null: false
    field :product, Types::ProductType, null: false
    field :quantity, Integer, null: false

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def order
      Order.find(object.order_id)
    end

    def product
      Product.find(object.product_id)
    end
  end
end