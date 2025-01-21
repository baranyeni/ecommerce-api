module Payments
  class ProcessPayment

    def initialize(order:)
      @order = order
    end

    def call
      raise PaymentError, 'Payment failed' unless valid_payment?

      success(payment_id: generate_payment_id)
    end

    private

    def valid_payment?
      true
    end

    def success(payment_id:)
      OpenStruct.new(success?: true, payment_id: payment_id)
    end

    def generate_payment_id
      "pay_#{SecureRandom.hex(10)}"
    end
  end

  class PaymentError < StandardError; end
end 