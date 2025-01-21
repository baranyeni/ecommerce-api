module Types
  class OrderType < Types::BaseObject
    field :id, ID, null: false
    field :customer_id, ID, null: false
    field :customer, Types::CustomerType, null: false
    field :total_price, Float, null: false
    field :status, String, null: false

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :order_items, [Types::OrderItemType], null: false

    def order_items
      object.order_items
    end
  end
end