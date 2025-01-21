# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe 'validations' do
    let(:order_item) { build(:order_item) }

    context 'when all attributes are valid' do
      it 'is valid' do
        expect(order_item).to be_valid
      end
    end

    context 'quantity validations' do
      it 'requires quantity' do
        order_item.quantity = nil
        expect(order_item).not_to be_valid
        expect(order_item.errors[:quantity]).to include("can't be blank")
      end

      it 'must be greater than 0' do
        order_item.quantity = 0
        expect(order_item).not_to be_valid
        expect(order_item.errors[:quantity]).to include("must be greater than 0")
      end
    end
  end

  describe 'associations' do
    let(:order_item) { create(:order_item) }

    it 'belongs to order' do
      expect(order_item.order).to be_present
    end

    it 'belongs to product' do
      expect(order_item.product).to be_present
    end
  end

  describe 'stock validation' do
    let(:product) { create(:product, stock_count: 5) }
    let(:order_item) { build(:order_item, product: product) }

    it 'allows quantity within stock limit' do
      order_item.quantity = 3
      expect(order_item).to be_valid
    end

    context 'before_save check_stock_availability' do
      it 'allows save when quantity within stock limit' do
        order_item.quantity = 3
        expect(order_item.save).to be true
      end

      it 'prevents save when quantity exceeds stock' do
        order_item.quantity = 6
        expect(order_item.save).to be false
        expect(order_item.errors[:quantity]).to include('is greater than available stock')
      end
    end
  end
end
