require 'rails_helper'

RSpec.describe OrderStateMachine do
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

    context 'when in_payment' do
      before { order.update!(status: :in_payment) }

      it 'can move to in_shipment' do
        expect(order.can_move_to_in_shipment?).to be true
        expect(order.move_to_in_shipment!).to be true
        expect(order.in_shipment?).to be true
      end

      it 'can move to dispute' do
        expect(order.can_move_to_dispute?).to be true
        expect(order.move_to_dispute!).to be true
        expect(order.dispute?).to be true
      end
    end

    context 'when in_shipment' do
      before { order.update!(status: :in_shipment) }

      it 'can move to completed' do
        expect(order.can_move_to_completed?).to be true
        expect(order.move_to_completed!).to be true
        expect(order.completed?).to be true
      end
    end

    context 'when completed' do
      before { order.update!(status: :completed) }

      it 'cannot move to any other status' do
        expect(order.move_to_active!).to be false
        expect(order.move_to_in_payment!).to be false
        expect(order.move_to_in_shipment!).to be false
        expect(order.move_to_dispute!).to be false
        expect(order.move_to_canceled!).to be false
      end
    end

    context 'when canceled' do
      before { order.update!(status: :canceled) }

      it 'cannot move to any other status' do
        expect(order.move_to_active!).to be false
        expect(order.move_to_in_payment!).to be false
        expect(order.move_to_in_shipment!).to be false
        expect(order.move_to_dispute!).to be false
        expect(order.move_to_completed!).to be false
      end
    end
  end

  describe 'validation conditions' do
    context 'when moving to in_payment' do
      before { order.update!(status: :active) }

      it 'requires items' do
        order.order_items.destroy_all
        expect(order.can_move_to_in_payment?).to be false
      end

      it 'requires positive total price' do
        allow(order).to receive(:total_price).and_return(0)
        expect(order.can_move_to_in_payment?).to be false
      end
    end

    context 'when moving to in_shipment' do
      before do 
        order.update!(status: :in_payment)
      end

      it 'requires payment to be completed' do
        allow(order).to receive(:payment_completed?).and_return(false)
        expect(order.can_move_to_in_shipment?).to be false
      end
    end
  end
end 