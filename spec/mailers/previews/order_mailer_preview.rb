# Preview all emails at http://localhost:3000/rails/mailers/order_mailer_mailer
class OrderMailerPreview < ActionMailer::Preview
  def successful_order
    order = Order.all.sample
    OrderMailer.successful_order(order)
  end
end
