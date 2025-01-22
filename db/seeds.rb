# frozen_string_literal: true

require_relative '../app/services/orders/create_from_cart'

customers = [
  { first_name: 'John', last_name: 'Doe', email: 'john.doe@example.com', phone_number: '+123 456 7899' },
  { first_name: 'Jane', last_name: 'Smith', email: 'jane.smith@example.com', phone_number: '+90 876 543 5214' },
  { first_name: 'Alice', last_name: 'Johnson', email: 'alice.johnson@example.com', phone_number: '(122) 334 3455' }
]

customers.each do |customer_data|
  Customer.create!(customer_data)
end

[
  { name: 'Product A', price: 10.0, stock_count: 100, description: 'Product A description' },
  { name: 'Product B', price: 20.0, stock_count: 50, description: 'Product B description' },
  { name: 'Product C', price: 15.0, stock_count: 75, description: 'Product C description' },
  { name: 'Product D', price: 25.0, stock_count: 25, description: 'Product D description' },
  { name: 'Product E', price: 30.0, stock_count: 10, description: 'Product E description' },
  { name: 'Product F', price: 35.0, stock_count: 5, description: 'Product F description' }
].each do |product_data|
  Product.create!(product_data)
end

Customer.all.each do |customer|
  cart = Cart.create!(customer: customer)

  cart_items = [
    { product: Product.find_by(name: 'Product A'), quantity: 2 },
    { product: Product.find_by(name: 'Product B'), quantity: 1 }
  ]

  cart_items.each do |cart_item_data|
    cart.cart_items.create!(cart_item_data)
  end
end

Orders::CreateFromCart.new(
  Customer.first.carts.first
).call

Order.all.last.update!(status: 'in_shipment')

puts "Seed data created successfully!"
