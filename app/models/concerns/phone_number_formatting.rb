module PhoneNumberFormatting
  extend ActiveSupport::Concern

  included do
    before_validation :sanitize_phone_number

    validates :phone_number, presence: true, format: { with: /\A[1-9]\d{9,14}\z/, message: "is invalid. Must be 10 digits" }
  end

  private

  def sanitize_phone_number
    return if phone_number.blank?

    self.phone_number = phone_number.gsub(/\D/, '').sub(/^90/, '').sub(/^0/, '')
  end
end
