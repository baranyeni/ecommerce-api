require 'rails_helper'

RSpec.describe 'CreateOrder Mutation', type: :request do
  let(:customer) { create(:customer) }
  let(:cart) { create(:cart, customer: customer, status: :active) }
  let!(:cart_items) { create_list(:cart_item, 2, cart: cart) }

  let(:mutation) do
    <<~GQL
      mutation {
        createOrder(customerId: "#{customer.id}", cartId: "#{cart.id}") {
          order {
              id status
              orderItems { id quantity product { name }
            }
          }
          errors
        }
      }
    GQL
  end

  def mutation_response
    JSON.parse(response.body).dig('data', 'createOrder')
  end

  it 'creates an order from cart' do
    expect do
      post '/graphql', params: { query: mutation }
    end.to change(Order, :count).by(1)
                                .and change(OrderItem, :count).by(2)
                                                              .and change {
                                                                     cart.reload.status
                                                                   }.from('active').to('completed')

    expect(mutation_response['errors']).to be_empty
    expect(mutation_response['order']).to include('status' => 'active')
    expect(mutation_response['order']['orderItems'].length).to eq(2)
  end

  context 'when customer not found' do
    let(:mutation) do
      <<~GQL
        mutation {
          createOrder(customerId: "0", cartId: "#{cart.id}") {
            order { id }
            errors
          }
        }
      GQL
    end

    it 'returns an error' do
      post '/graphql', params: { query: mutation }

      expect(mutation_response['order']).to be_nil
      expect(mutation_response['errors']).to include('Customer not found')
    end
  end

  context 'when cart is empty' do
    before { cart.cart_items.destroy_all }

    it 'returns an error' do
      post '/graphql', params: { query: mutation }

      expect(mutation_response['order']).to be_nil
      expect(mutation_response['errors']).to include('Cart is empty')
    end
  end

  context 'when payment fails' do
    before do
      allow_any_instance_of(Payments::ProcessPayment).to receive(:valid_payment?).and_return(false)
    end

    it 'creates order with failed payment status' do
      expect do
        post '/graphql', params: { query: mutation }
      end.to change(Order, :count).by(0)
                                  .and change(OrderItem, :count).by(0)

      expect(cart.reload.status).to eq('active')
      expect(mutation_response['errors']).to include('Payment failed')
    end
  end
end
