require 'rails_helper'

RSpec.describe OrderMailerJob, type: :job do
  let(:order) { create(:order) }
  let(:mailer_method) { :send_successful_order_email }

  describe '#perform' do
    it 'calls the correct mailer method' do
      expect(OrderMailer).to receive(:successful_order).with(order).and_call_original

      OrderMailerJob.perform_now(order, mailer_method)
    end
  end
end
