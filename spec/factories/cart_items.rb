FactoryBot.define do
  factory :cart_item do
    cart
    product { create(:product, stock_count: 10) }
    quantity { 1 }

    trait :multiple_quantity do
      quantity { 2 }
    end

    trait :with_out_of_stock_product do
      association :product, :out_of_stock
    end
  end
end
