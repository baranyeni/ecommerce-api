# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::Mutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    object_class Types::BaseObject

    # This line is commented out because we don't want to use relay along with input object
    # input_object_class Types::BaseInputObject
  end
end
