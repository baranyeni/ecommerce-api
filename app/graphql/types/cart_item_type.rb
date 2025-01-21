module Types
  class CartItemType < Types::BaseObject
    field :id, ID, null: false
    field :cart_id, ID, null: false
    field :product_id, ID, null: false
    field :quantity, Integer, null: false
    field :product, Types::ProductType, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end