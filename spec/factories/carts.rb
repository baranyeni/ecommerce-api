FactoryBot.define do
  factory :cart do
    customer
    status { Cart.statuses[:active] }

    trait :cart_with_items do
      transient do
        items_count { 3 }
      end

      after(:create) do |cart, evaluator|
        create_list(:cart_item, evaluator.items_count, cart: cart)
      end
    end
  end
end
