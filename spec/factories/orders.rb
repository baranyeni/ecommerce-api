FactoryBot.define do
  factory :order do
    customer
    total_price { 100.00 }

    after(:build) do |order|
      product = create(:product, price: 10.0, stock_count: 100)

      order.order_items << build(:order_item,
                                 order: order,
                                 product: product,
                                 quantity: 25)

      order.total_price = order.order_items.sum { |item| item.quantity * item.product.price }
    end
  end
end
