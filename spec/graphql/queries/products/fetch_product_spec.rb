require 'rails_helper'

RSpec.describe 'FetchProduct Query', type: :request do
  let!(:product) { create(:product) }
  
  let(:query) do
    <<-GRAPHQL
      query { product(id: "#{product.id}") { id name description price stockCount } }
    GRAPHQL
  end

  def query_response
    JSON.parse(response.body).dig('data', 'product')
  end

  it 'returns the product' do
    post '/graphql', params: { query: query }

    expect(query_response['id']).to eq(product.id.to_s)
    expect(query_response['name']).to eq(product.name)
    expect(query_response['description']).to eq(product.description)
    expect(query_response['price'].to_s).to eq(product.price.to_s)
    expect(query_response['stockCount']).to eq(product.stock_count)
  end

  context 'when product does not exist' do
    let(:query) do
      <<-GRAPHQL
        query { product(id: "0") { id name description price stockCount } }
      GRAPHQL
    end

    it 'returns null' do
      post '/graphql', params: { query: query }

      expect(query_response).to be_nil
    end
  end
end 