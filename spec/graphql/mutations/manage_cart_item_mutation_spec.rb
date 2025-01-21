require 'rails_helper'

RSpec.describe 'ManageCartItem Mutation', type: :request do
  let(:customer) { create(:customer) }
  let(:product) { create(:product, stock_count: 5) }
  
  let(:query) do
    <<-GRAPHQL
      mutation {
        manageCartItem( customerId: "#{customer.id}", productId: "#{product.id}", quantity: #{quantity} ) {
          cart { id status subtotal }
          cartItem { id quantity product { name description price } }
          errors
        }
      }
    GRAPHQL
  end

  context 'when adding new item to cart' do
    let(:quantity) { 2 }

    it 'creates new cart item' do
      post '/graphql', params: { query: query }

      data = JSON.parse(response.body)['data']['manageCartItem']

      expect(data['errors']).to be_empty
      expect(data['cartItem']['quantity']).to eq(2)
      expect(data['cart']['status']).to eq('active')
    end
  end

  context 'when updating existing cart item overwriting quantity' do
    let!(:cart) { create(:cart, customer: customer, status: :active) }
    let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }
    let(:quantity) { 3 }

    it 'updates cart item quantity' do
      post '/graphql', params: { query: query }

      data = JSON.parse(response.body)['data']['manageCartItem']

      expect(data['errors']).to be_empty
      expect(data['cartItem']['quantity']).to eq(3)
    end
  end

  context 'when removing item from cart' do
    let!(:cart) { create(:cart, customer: customer, status: :active) }
    let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }
    let(:quantity) { 0 }

    it 'removes cart item' do
      expect {
        post '/graphql', params: { query: query }
      }.to change(CartItem, :count).by(-1)

      data = JSON.parse(response.body)['data']['manageCartItem']

      expect(data['errors']).to be_empty
      expect(data['cartItem']).to be_nil
    end
  end

  context 'when quantity exceeds stock' do
    let(:quantity) { 6 }

    it 'returns an error' do
      post '/graphql', params: { query: query }

      data = JSON.parse(response.body)['data']['manageCartItem']

      expect(data['cartItem']).to be_nil
      expect(data['errors']).to include('Requested quantity is not available')
    end
  end

  context 'when product not found' do
    let(:quantity) { 1 }

    it 'returns an error' do
      product.destroy
      post '/graphql', params: { query: query }
      data = JSON.parse(response.body)['data']['manageCartItem']

      expect(data['cartItem']).to be_nil
      expect(data['errors']).to include('Product not found')
    end
  end

  context 'when customer not found' do
    let(:quantity) { 1 }

    it 'returns an error' do
      customer.destroy
      post '/graphql', params: { query: query }
      data = JSON.parse(response.body)['data']['manageCartItem']

      expect(data['cartItem']).to be_nil
      expect(data['errors']).to include('Customer not found')
    end
  end
end 