module Queries
  module Customers
    class FetchCustomer < Queries::BaseQuery
      type Types::CustomerType, null: true
      description "Get a customer by ID"

      argument :id, ID, required: true

      def resolve(id:)
        Customer.find_by(id: id)
      end
    end
  end
end 