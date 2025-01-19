# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Customer Query', type: :request do
  let!(:customer) { create_list(:customer, 3) }

  it 'fetches all customers' do
    query = <<-GRAPHQL
      query { customers { id firstName lastName email phoneNumber } }
    GRAPHQL

    post '/graphql', params: { query: query }

    result = JSON.parse(response.body)['data']['customers']
    all_customers = Customer.all

    expect(response).to have_http_status(:ok)
    %w[id firstName lastName email phoneNumber].each do |key|
      expect(result.map { |d| d[key].to_s }).to match_array(all_customers.map(&key.underscore.to_sym).map(&:to_s))
    end
  end

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
end
