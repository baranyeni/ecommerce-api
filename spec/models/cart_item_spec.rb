require 'rails_helper'

RSpec.describe CartItem, type: :model do
  describe 'validations' do
    let(:cart_item) { build(:cart_item) }

    context 'when all attributes are valid' do
      it 'is valid' do
        expect(cart_item).to be_valid
      end
    end

    context 'quantity validations' do
      it 'requires quantity' do
        cart_item.quantity = nil
        expect(cart_item).not_to be_valid
        expect(cart_item.errors[:quantity]).to include("can't be blank")
      end

      it 'must be greater than 0' do
        cart_item.quantity = 0
        expect(cart_item).not_to be_valid
        expect(cart_item.errors[:quantity]).to include("must be greater than 0")
      end
    end

    context 'association validations' do
      it 'requires cart' do
        cart_item.cart = nil
        expect(cart_item).not_to be_valid
        expect(cart_item.errors[:cart]).to include("must exist")
      end

      it 'requires product' do
        cart_item.product = nil
        expect(cart_item).not_to be_valid
        expect(cart_item.errors[:product]).to include("must exist")
      end
    end
  end

  describe 'associations' do
    let(:cart_item) { create(:cart_item) }

    it 'belongs to cart' do
      expect(cart_item.cart).to be_present
      expect(cart_item.cart).to be_a(Cart)
    end

    it 'belongs to product' do
      expect(cart_item.product).to be_present
      expect(cart_item.product).to be_a(Product)
    end
  end

  describe 'callbacks' do
    context 'before_save check_stock_availability' do
      let(:product) { create(:product, stock_count: 5) }
      let(:cart_item) { build(:cart_item, product: product) }

      context 'when quantity is within stock limit' do
        it 'allows save' do
          cart_item.quantity = 3
          expect(cart_item.save).to be true
        end
      end

      context 'when quantity equals stock limit' do
        it 'allows save' do
          cart_item.quantity = 5
          expect(cart_item.save).to be true
        end
      end

      context 'when quantity exceeds stock limit' do
        before do
          cart_item.quantity = 6
        end

        it 'prevents save' do
          expect(cart_item.save).to be false
        end

        it 'adds error message' do
          cart_item.save
          expect(cart_item.errors[:quantity]).to include('is greater than available stock')
        end
      end

      context 'when updating existing cart item' do
        let!(:cart_item) { create(:cart_item, product: product, quantity: 2) }

        it 'allows update within stock limit' do
          expect(cart_item.update(quantity: 4)).to be true
        end

        it 'prevents update exceeding stock limit' do
          expect(cart_item.update(quantity: 6)).to be false
          expect(cart_item.errors[:quantity]).to include('is greater than available stock')
        end
      end
    end
  end
end
