class Customer < ApplicationRecord
  include PhoneNumberFormatting

  validates :first_name, :last_name, :email, :phone_number, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
end
