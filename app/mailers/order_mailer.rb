# frozen_string_literal: true

class OrderMailer < ApplicationMailer
  def successful_order(order)
    @order = order
    mail(to: @order.customer.email, subject: 'Order Confirmation')
  end
end
