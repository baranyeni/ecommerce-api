module Queries
  module Products
    class FetchProduct < Queries::BaseQuery
      type Types::ProductType, null: true
      description "Get a product by ID"

      argument :id, ID, required: true

      def resolve(id:)
        Product.find_by(id: id)
      end
    end
  end
end
