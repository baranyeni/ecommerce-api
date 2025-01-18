class Customer < ApplicationRecord
  include PhoneNumberFormatting

  validates :name, :surname, :email, :phone_number, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
end
