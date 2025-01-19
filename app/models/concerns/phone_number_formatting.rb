# frozen_string_literal: true

module PhoneNumberFormatting
  extend ActiveSupport::Concern

  included do
    before_validation :sanitize_phone_number
  end

  private

  def sanitize_phone_number
    return if phone_number.blank?

    self.phone_number = phone_number.gsub(/\D/, '').sub(/^90/, '').sub(/^0/, '')
  end
end
