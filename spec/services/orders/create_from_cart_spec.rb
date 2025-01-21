require 'rails_helper'

RSpec.describe Orders::CreateFromCart do
  let(:customer) { create(:customer) }
  let(:cart) { create(:cart, customer: customer) }
  let(:service) { described_class.new(cart) }

  describe '#call' do
    context 'when cart is empty' do
      it 'returns failure result' do
        result = service.call

        expect(result.success?).to be false
        expect(result.error).to eq('Cart is empty')
      end
    end

    context 'when some products are out of stock' do
      let!(:product) { create(:product, stock_count: 2) }

      before do
        create(:cart_item, cart: cart, product: product, quantity: 2)
      end

      it 'returns failure result' do
        product.update!(stock_count: 1)
        result = service.call

        expect(result.success?).to be false
        expect(result.error).to eq('Some products are out of stock')
      end
    end

    context 'when successful' do
      let!(:product) { create(:product, stock_count: 5, price: 10.00) }

      before do
        create(:cart_item, cart: cart, product: product, quantity: 2)
      end

      it 'creates an order with correct attributes' do
        result = service.call

        expect(result.success?).to be true
        expect(result.error).to be_nil

        order = result.data
        expect(order).to be_an(Order)
        expect(order.customer).to eq(customer)
        expect(order.order_items.count).to eq(1)

        order_item = order.order_items.first
        expect(order_item.product).to eq(product)
        expect(order_item.quantity).to eq(2)
        expect(order_item.order.total_price).to eq(20.00)
      end

      it 'reserves product stock' do
        expect do
          service.call
        end.to change { product.reload.stock_count }.from(5).to(3)
      end

      it 'moves the cart to completed status' do
        expect do
          service.call
        end.to change(Cart.completed, :count).by(1)
      end
    end

    context 'when database error occurs' do
      let!(:product) { create(:product, stock_count: 5) }

      before do
        create(:cart_item, cart: cart, product: product, quantity: 2)
        allow(Order).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Order.new))
      end

      it 'returns failure result' do
        result = service.call

        expect(result.success?).to be false
        expect(result.error).to be_present
      end

      it 'does not change product stock' do
        expect do
          service.call
        end.not_to(change { product.reload.stock_count })
      end

      it 'does not destroy cart' do
        expect do
          service.call
        end.not_to change(Cart, :count)
      end
    end

    context 'when state transition is invalid' do
      let(:order) { create(:order) }

      describe 'state transitions' do
        context 'when active' do
          before { order.update!(status: :active) }

          it 'can move to in_payment if valid' do
            expect(order.can_move_to_in_payment?).to be true
            expect(order.move_to_in_payment!).to be true
            expect(order.in_payment?).to be true
          end

          it 'cannot move to completed directly' do
            expect(order.can_move_to_completed?).to be false
            expect(order.move_to_completed!).to be false
            expect(order.completed?).to be false
          end
        end
      end
    end
  end
end
