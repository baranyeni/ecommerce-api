module Mutations
  class CreateCustomer < BaseMutation
    argument :first_name, String, required: true
    argument :last_name, String, required: true
    argument :email, String, required: true
    argument :phone_number, String, required: true

    field :customer, Types::CustomerType, null: true
    field :errors, [String], null: false

    def resolve(first_name: nil, last_name: nil, email: nil, phone_number: nil)
      customer = Customer.new(first_name: first_name, last_name: last_name, email: email, phone_number: phone_number)
      if customer.save
        {customer: customer, errors: []}
      else
        {customer: nil, errors: customer.errors.full_messages}
      end
    end
  end
end