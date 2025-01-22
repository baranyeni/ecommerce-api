require "rails_helper"

RSpec.describe OrderMailer, type: :mailer do
  describe 'successful_order' do
    let(:order) { create(:order) }
    let(:mail) { OrderMailer.successful_order(order) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Order Confirmation')
      expect(mail.to).to eq([order.customer.email])
      expect(mail.from).to eq(['from@example.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match(order.id.to_s)
      expect(mail.body.encoded).to match(order.customer.full_name)
      order.order_items.each do |item|
        expect(mail.body.encoded).to match(item.product.name)
        expect(mail.body.encoded).to match(item.quantity.to_s)
      end
    end
  end
end
