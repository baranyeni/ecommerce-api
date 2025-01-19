# frozen_string_literal: true

FactoryBot.define do
  factory :customer do
    first_name { 'John' }
    last_name { 'Doe' }

    sequence :email do |n|
      "john.doe#{n}@example.com"
    end

    sequence :phone_number do |n|
      "123456789#{n}"[-10...]
    end
  end
end
