module OrderStateMachine
  extend ActiveSupport::Concern

  def valid_transition?(new_status)
    case status
    when 'active'
      %w[in_payment canceled].include?(new_status)
    when 'in_payment'
      %w[in_shipment dispute canceled].include?(new_status)
    when 'in_shipment'
      %w[completed dispute canceled].include?(new_status)
    when 'dispute'
      %w[completed canceled].include?(new_status)
    when 'canceled', 'completed'
      false
    else
      false
    end
  end

  def can_move_to_active?
    return false if active?
    valid_transition?('active')
  end

  def can_move_to_in_payment?
    return false unless active?
    return false if order_items.empty?
    return false if total_price.zero?
    true
  end

  def can_move_to_in_shipment?
    return false unless in_payment?
    return false unless payment_completed?
    true
  end

  def can_move_to_completed?
    return false unless in_shipment?
    return false unless shipping_completed?
    true
  end

  def can_move_to_dispute?
    return false unless in_payment? || in_shipment?
    true
  end

  def can_move_to_canceled?
    return false if completed? || canceled?
    true
  end

  def payment_completed?
    true
  end

  def shipping_completed?
    true
  end
end 