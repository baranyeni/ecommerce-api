class Customer < ApplicationRecord
  include PhoneNumberFormatting

  validates :first_name, :last_name, :email, :phone_number, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :phone_number, presence: true, uniqueness: true,
            format: { with: /\A[1-9]\d{9,14}\z/, message: "is invalid. Must be 10 digits" }
end
