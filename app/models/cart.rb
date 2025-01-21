# frozen_string_literal: true

class Cart < ApplicationRecord
  include ShippingCalculable
  include CartCalculations

  enum status: { active: 0, processing: 1, returned: 2, canceled: 3, completed: 4 }.freeze

  belongs_to :customer
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates :customer, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }


  scope :active, -> { where(status: :active) }
  scope :completed, -> { where(status: :completed) }
  scope :abandoned, -> { where(status: :abandoned) }

  statuses.keys.each do |status_name|
    define_method("move_to_#{status_name}!") do
      return false if status == status_name

      update!(status: status_name)
      true
    end
  end
end
