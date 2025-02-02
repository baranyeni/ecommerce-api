# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_customer, mutation: Mutations::CreateCustomer
    field :manage_cart_item, mutation: Mutations::ManageCartItem
    field :create_order, mutation: Mutations::CreateOrder
  end
end
