# @frozen_string_literal: true

require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'validations' do
    let(:order) { build(:order) }

    context 'when all attributes are valid' do
      it 'is valid' do
        expect(order).to be_valid
      end
    end

    context 'customer validation' do
      it 'requires customer' do
        order.customer = nil
        expect(order).not_to be_valid
        expect(order.errors[:customer]).to include('must exist')
      end
    end

    context 'total price validation' do
      it 'validates total price is greater than 0' do
        order.total_price = 0
        expect(order).not_to be_valid
        expect(order.errors[:total_price]).to include('must be greater than 0')
      end
    end

    context 'status validation' do
      it 'requires status' do
        order.status = nil
        expect(order).not_to be_valid
        expect(order.errors[:status]).to include("can't be blank")
      end

      it 'has default status of pending' do
        expect(Order.new.status).to eq('active')
      end
    end
  end

  describe 'associations' do
    let(:order) { create(:order) }
    let(:product) { create(:product) }

    it 'has many order items' do
      order_item = order.order_items.create(product: product, quantity: 2)
      expect(order.order_items).to include(order_item)
    end

    it 'belongs to customer' do
      expect(order.customer).to be_present
      expect(order.customer).to be_a(Customer)
    end

    it 'destroys dependent order items when destroyed' do
      order.order_items.create(product: product, quantity: 2)
      expect { order.destroy }.to raise_error(ActiveRecord::InvalidForeignKey)
    end
  end

  describe 'calculations' do
    let(:order) { create(:order) }
    let(:product1) { create(:product, price: 10.0, unit_size: 0.5, unit_name: :kg) }
    let(:product2) { create(:product, price: 20.0, unit_size: 1.0, unit_name: :kg) }
    let(:product3) { create(:product, price: 5.0, unit_size: 1.0, unit_name: :qty) }

    before do
      order.order_items.destroy_all
      order.order_items.create(product: product1, quantity: 2)
      order.order_items.create(product: product2, quantity: 1)
      order.order_items.create(product: product3, quantity: 3)
    end

    describe '#total_price' do
      it 'calculates total price correctly' do
        expect(order.current_total_price.to_i).to eq(55.0)
      end
    end
  end

  describe 'state machine' do
    let(:order) { create(:order) }

    context 'initial state' do
      it 'starts with pending status' do
        expect(order.status).to eq('active')
      end
    end

    context 'when status is active' do
      before { order.update!(status: :active) }

      it 'can transition to in_payment with valid conditions' do
        create(:order_item, order: order)
        expect(order.can_move_to_in_payment?).to be true
      end

      it 'cannot transition to in_payment with empty cart' do
        order.order_items.destroy_all
        expect(order.can_move_to_in_payment?).to be false
      end
    end

    context 'when status is in_payment' do
      before { order.update!(status: :in_payment) }

      it 'can transition to in_shipment when payment completed' do
        allow(order).to receive(:payment_completed?).and_return(true)
        expect(order.can_move_to_in_shipment?).to be true
      end

      it 'can transition to dispute or canceled' do
        expect(order.can_move_to_dispute?).to be true
        expect(order.can_move_to_canceled?).to be true
      end
    end

    context 'when status is completed or canceled' do
      it 'cannot transition to any status when completed' do
        order.update!(status: :completed)
        expect(order.valid_transition?('canceled')).to be false
      end

      it 'cannot transition to any status when canceled' do
        order.update!(status: :canceled)
        expect(order.valid_transition?('completed')).to be false
      end
    end
  end
end
