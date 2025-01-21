# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Customer, type: :model do
  attrs = %i[first_name last_name email phone_number]

  let(:customer) { create(:customer) }
  let(:valid_attributes) do
    { first_name: 'John', last_name: 'Doe', email: 'john.doe@example.com', phone_number: '+1234567890' }
  end

  describe 'associations' do
    let(:customer) { create(:customer) }

    it 'has many carts' do
      cart1 = create(:cart, customer: customer)
      cart2 = create(:cart, customer: customer)

      expect(customer.carts).to include(cart1, cart2)
    end

    it 'has one active cart' do
      cart = create(:cart, customer: customer)
      expect(customer.active_cart).to eq(cart)
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      customer = Customer.new(valid_attributes)
      expect(customer).to be_valid
    end

    attrs.each do |attr|
      it "is not valid without #{attr} attribute" do
        customer = Customer.new(valid_attributes.except(attr))
        expect(customer).to be_invalid
        expect(customer.errors[attr]).to include("can't be blank")
      end
    end

    it 'is not valid with a duplicate email' do
      create(:customer, email: valid_attributes[:email])
      customer = Customer.new(valid_attributes)
      expect(customer).to be_invalid
      expect(customer.errors[:email]).to include('has already been taken')
    end

    it 'is not valid with a duplicate phone number' do
      create(:customer, phone_number: valid_attributes[:phone_number])
      customer = Customer.new(valid_attributes)
      expect(customer).to be_invalid
      expect(customer.errors[:phone_number]).to include('has already been taken')
    end

    it 'is invalid with an invalid email' do
      customer = Customer.new(valid_attributes.merge(email: 'invalid-email'))
      expect(customer).to be_invalid
      expect(customer.errors[:email]).to include('is invalid')
    end

    it 'is invalid with an invalid phone number' do
      %w[+123456 1234123412341234 invalid-number].each do |phone_number|
        customer = Customer.new(valid_attributes.merge(phone_number: phone_number))
        expect(customer).to be_invalid
        expect(customer.errors[:phone_number]).to include('is invalid. Must be 10 digits')
      end
    end
  end

  describe 'concerns' do
    context 'phone number formatting' do
      it 'removes non-digit characters' do
        expect(Customer.create(valid_attributes.merge(phone_number: '+1 (234) 567-890')).phone_number).to eq('1234567890')
      end

      it 'trim whitespaces' do
        expect(Customer.create(valid_attributes.merge(phone_number: ' 123456789')).phone_number).to eq('123456789')
      end

      it 'removes leading 0s' do
        expect(Customer.create(valid_attributes.merge(phone_number: '01234567890')).phone_number).to eq('1234567890')
      end

      it 'removes country code of Turkey\'s' do
        expect(Customer.create(valid_attributes.merge(phone_number: '901234567890')).phone_number).to eq('1234567890')
      end
    end
  end
end
