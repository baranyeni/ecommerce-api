class OrderMailerJob < ApplicationJob
  queue_as :mailers

  def perform(order, mailer_method)
    send(mailer_method, order)
  end

  def send_successful_order_email(order)
    OrderMailer.successful_order(order).deliver_now
  end
end
