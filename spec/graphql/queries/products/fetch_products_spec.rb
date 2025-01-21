require 'rails_helper'

RSpec.describe 'FetchProducts Query', type: :request do
  let!(:products) { create_list(:product, 3) }

  let(:query) do
    <<-GRAPHQL
      query {
        products { id name description price stockCount }
      }
    GRAPHQL
  end

  def query_response
    JSON.parse(response.body).dig('data', 'products')
  end

  it 'returns all products' do
    post '/graphql', params: { query: query }

    expect(query_response.length).to eq(3)
    expect(query_response.first.keys).to match_array(%w[id name description price stockCount])

    first_product = products.first
    first_response = query_response.first
    expect(first_response['id']).to eq(first_product.id.to_s)
    expect(first_response['name']).to eq(first_product.name)
    expect(first_response['description']).to eq(first_product.description)
    expect(first_response['price'].to_s).to eq(first_product.price.to_s)
    expect(first_response['stockCount']).to eq(first_product.stock_count)
  end

  context 'with pagination' do
    let!(:additional_products) { create_list(:product, 2) }

    let(:query_with_pagination) do
      <<-GRAPHQL
        query {
          products(limit: 2, offset: 1) { id name description price stockCount }
        }
      GRAPHQL
    end

    it 'returns paginated products' do
      post '/graphql', params: { query: query_with_pagination }

      expect(query_response.length).to eq(2)
      product_ids = Product.offset(1).limit(2).pluck(:id).map(&:to_s)
      response_ids = query_response.map { |p| p['id'] }
      expect(response_ids).to match_array(product_ids)
    end
  end

  context 'when no products exist' do
    before { Product.destroy_all }

    it 'returns an empty array' do
      post '/graphql', params: { query: query }

      expect(query_response).to be_empty
    end
  end
end
