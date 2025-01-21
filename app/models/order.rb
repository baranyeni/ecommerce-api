# frozen_string_literal: true

class Order < ApplicationRecord
  include ShippingCalculable
  include OrderStateMachine

  enum status: { active: 0, in_payment: 1, in_shipment: 2, dispute: 3, canceled: 4, completed: 5 }.freeze

  belongs_to :customer
  has_many :order_items
  has_many :products, through: :order_items

  accepts_nested_attributes_for :order_items

  validates_presence_of :order_items
  validates :total_price, numericality: { greater_than: 0 }, allow_nil: true
  validates :status, presence: true, inclusion: { in: statuses.keys }

  scope :active, -> { where(status: :active) }
  scope :in_payment, -> { where(status: :in_payment) }
  scope :in_shipment, -> { where(status: :in_shipment) }
  scope :dispute, -> { where(status: :dispute) }
  scope :canceled, -> { where(status: :canceled) }
  scope :completed, -> { where(status: :completed) }

  statuses.keys.each do |status_name|
    define_method("move_to_#{status_name}!") do
      return false if status == status_name
      return false unless send("can_move_to_#{status_name}?")

      update!(status: status_name)
      true
    end
  end
  def total_price
    order_items.includes(:product).sum { |item| item.quantity * item.product.price }
  end
end
