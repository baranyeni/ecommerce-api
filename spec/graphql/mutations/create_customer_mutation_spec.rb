# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Customer Mutation', type: :request do
  let(:params) do {
      firstName: 'John',
      lastName: 'Doe',
      email: 'john_doe@example.com',
      phoneNumber: '1234567890'
    }
  end

  shared_examples 'fails to create customer' do |error_message, value:|
    let(:params_) { instance_exec(&value) }

    it "returns validation error '#{error_message}' " do
      query = <<-GRAPHQL
        mutation {
          createCustomer(firstName: "#{params_[:firstName]}", lastName: "#{params_[:lastName]}",
                         email: "#{params_[:email]}", phoneNumber: "#{params_[:phoneNumber]}") {
            customer { id firstName lastName email phoneNumber }
            errors
          }
        }
      GRAPHQL

      post '/graphql', params: { query: query }

      json = JSON.parse(response.body)
      errors = json['data']['createCustomer']['errors']

      expect(response).to have_http_status(:ok)
      expect(errors).to include(error_message)
    end
  end

  context 'with valid parameters' do
    it 'creates a customer' do
      query = <<-GRAPHQL
        mutation {
          createCustomer(firstName: "#{params[:firstName]}", lastName: "#{params[:lastName]}", email: "#{params[:email]}", phoneNumber: "#{params[:phoneNumber]}") {
            customer { id firstName lastName email phoneNumber }
          }
        }
      GRAPHQL

      post '/graphql', params: { query: query }

      json = JSON.parse(response.body)
      data = json['data']['createCustomer']['customer']

      expect(response).to have_http_status(:ok)
      %w[firstName lastName email phoneNumber].each do |key|
        expect(data[key]).to eq(params[key.to_sym])
      end
    end
  end

  context 'with invalid parameters' do
    it_behaves_like 'fails to create customer', 'First name can\'t be blank', value: -> { params.merge(firstName: nil) }
    it_behaves_like 'fails to create customer', 'Email is invalid', value: -> { params.merge(email: 'invalid_email') }
    it_behaves_like 'fails to create customer', 'Phone number is invalid. Must be 10 digits',
                    value: -> { params.merge(phoneNumber: '12345') }
  end
end
