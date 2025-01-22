# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Customer Query', type: :request do
  let!(:customer) { create_list(:customer, 3) }

  it 'fetches a customer by ID' do
    customer = create(:customer)

    query = <<-GRAPHQL
      query { customer(id: "#{customer.id}") { id firstName lastName email phoneNumber } }
    GRAPHQL

    post '/graphql', params: { query: query }

    result = JSON.parse(response.body)['data']['customer']

    expect(response).to have_http_status(:ok)
    %w[id firstName lastName email phoneNumber].each do |key|
      expect(result[key].to_s).to eq(customer[key.underscore.to_sym].to_s)
    end
  end

  it 'returns a customer including their active cart' do
    customer = create(:customer)
    create(:cart, customer: customer)
    create(:cart_item, cart: customer.active_cart)

    query = "query { customer(id: #{customer.id}) { activeCart { id subtotal } } }"

    post '/graphql', params: { query: query }

    result = JSON.parse(response.body)['data']['customer']['activeCart']
    expect(result['id']).to eq(customer.active_cart.id.to_s)
    expect(result['subtotal'].to_s).to eq(customer.active_cart.subtotal.to_s)
  end

  it 'returns a customer including their ongoning orders' do
    customer = create(:customer)
    create(:order, customer: customer, status: :in_shipment)
    create(:order, customer: customer, status: :completed)

    query = "query { customer(id: #{customer.id}) { ongoingOrders { id status } } }"

    post '/graphql', params: { query: query }

    result = JSON.parse(response.body)['data']['customer']['ongoingOrders']
    expect(result.count).to eq(1)
    expect(result.first['id']).to eq(customer.orders.in_shipment.first.id.to_s)
    expect(result.first['status']).to eq('in_shipment')
  end
end
