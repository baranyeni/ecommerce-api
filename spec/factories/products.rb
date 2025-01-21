FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    description { 'A detailed description' }
    price { 10.00 }
    stock_count { 10 }
    unit_size { 1.0 }
    unit_name { Product.unit_names.keys.sample }
    lock_version { 0 }
    obsolete { false }
    deleted_at { nil }

    trait :out_of_stock do
      stock_count { 0 }
    end

    trait :low_stock do
      stock_count { Product::LOW_STOCK_THRESHOLD - 1 }
    end

    trait :obsolete do
      obsolete { true }
    end
  end
end
