# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_customer, mutation: Mutations::CreateCustomer
  end
end
