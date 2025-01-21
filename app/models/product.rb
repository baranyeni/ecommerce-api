# frozen_string_literal: true

class Product < ApplicationRecord
  enum unit_name: { qty: 0, package: 1, kg: 2, gr: 3 }.freeze

  scope :available, -> { where(obsolete: false, deleted_at: nil) }
  scope :obsolete, -> { where(obsolete: true) }

  validates :name, presence: true, length: { maximum: 255 }
  validates :description, presence: true, length: { maximum: 1000 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :unit_size, presence: true, numericality: { greater_than: 0 }
  validates :stock_count, numericality: { greater_than_or_equal_to: 0 }
  validates :unit_name, presence: true

  def available_for_quantity?(requested_quantity)
    return false if obsolete?
    stock_count >= requested_quantity
  end

  def reserve_stock(quantity)
    with_lock do
      return false unless available_for_quantity?(quantity)
      update!(stock_count: stock_count - quantity)
      true
    end
  end
end
