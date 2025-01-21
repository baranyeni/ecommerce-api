# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    # Add Relay Node interface
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Customer
    field :customer, resolver: Queries::Customers::FetchCustomer

    # Products
    field :products, resolver: Queries::Products::FetchProducts
    field :product, resolver: Queries::Products::FetchProduct

  end
end
