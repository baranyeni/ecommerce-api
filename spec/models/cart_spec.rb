# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cart, type: :model do
  describe 'validations' do
    let(:cart) { build(:cart) }

    context 'when all attributes are valid' do
      it 'is valid' do
        expect(cart).to be_valid
      end
    end

    context 'status validation' do
      it 'requires status' do
        cart.status = nil
        expect(cart).not_to be_valid
        expect(cart.errors[:status]).to include("can't be blank")
      end

      it 'validates status inclusion' do
        expect do
          cart.status = 'invalid'
        end.to raise_error(ArgumentError, '\'invalid\' is not a valid status')
      end
    end

    context 'customer validation' do
      it 'requires customer' do
        cart.customer = nil
        expect(cart).not_to be_valid
        expect(cart.errors[:customer]).to include('must exist')
      end
    end

    context 'cart items validation' do
      let(:product) { create(:product) }

      it 'allows cart without items' do
        expect(cart).to be_valid
      end

      it 'allows cart with valid items' do
        cart.save
        cart.cart_items.create(product: product, quantity: 1)
        expect(cart).to be_valid
      end

      it 'validates associated cart items' do
        cart.save
        invalid_item = cart.cart_items.create(product: nil, quantity: 1)
        expect(invalid_item).not_to be_valid
        expect(invalid_item.errors[:product]).to include('must exist')
      end
    end
  end

  describe 'associations' do
    let(:cart) { create(:cart) }
    let(:customer) { create(:customer) }
    let(:product) { create(:product) }

    context 'when adding items' do
      it 'can add cart items' do
        cart_item = cart.cart_items.create(
          product: product,
          quantity: 2
        )
        expect(cart.cart_items).to include(cart_item)
      end

      it 'belongs to customer' do
        cart.update(customer: customer)
        expect(cart.customer).to eq(customer)
      end
    end

    it 'has many products through cart items' do
      cart.cart_items.create(product: product, quantity: 1)
      expect(cart.products).to include(product)
    end

    it 'destroys dependent cart items when destroyed' do
      cart.cart_items.create(product: product, quantity: 1)
      expect { cart.destroy }.to change(CartItem, :count).by(-1)
    end
  end

  describe '#total_price' do
    let(:cart) { create(:cart) }
    let(:product1) { create(:product, price: 10.0) }
    let(:product2) { create(:product, price: 20.0) }

    context 'when cart has items' do
      before do
        cart.cart_items.create(product: product1, quantity: 2)
        cart.cart_items.create(product: product2, quantity: 1)
      end

      it 'calculates total price correctly' do
        expect(cart.subtotal).to eq(40.0)
        expect(cart.total_price).to eq(63.0)
      end
    end

    context 'when cart is empty' do
      it 'returns zero' do
        expect(cart.subtotal).to eq(0)
        expect(cart.total_price).to eq(15)
      end
    end
  end
end
