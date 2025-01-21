module Queries
  module Products
    class FetchProducts < Queries::BaseQuery
      type [Types::ProductType], null: false
      description "Get all products"

      argument :limit, Integer, required: false
      argument :offset, Integer, required: false

      def resolve(limit: nil, offset: nil)
        products = Product.all
        products = products.limit(limit) if limit
        products = products.offset(offset) if offset
        products
      end
    end
  end
end 