# frozen_string_literal: true

# Module Ronflex
#
# This module encapsulates functionality related to rule-based access control.
# The `Rule` class within this module represents a single rule that determines
# whether a specific model (e.g., a user or role) is allowed access to a given request.
module Ronflex
  # Class Rule
  #
  # Represents a rule that associates a specific type (e.g., `:admin`, `:guest`) with 
  # a custom condition defined by a block of logic. The rule can then evaluate whether 
  # a model matches the type and satisfies the condition for a particular request.
  class Rule
    # @return [Symbol, String] the type of the model this rule applies to (e.g., `:admin` or `:guest`).
    attr_reader :type

    # @return [Proc] the block of logic that determines if the rule matches a given model and request.
    attr_reader :rule

    # Initializes a new rule.
    #
    # @param type [Symbol, String] The type of model this rule applies to.
    #   Typically a symbol representing a role (e.g., `:admin` or `:guest`).
    # @yield [model, request] The block defining the rule's logic. It is executed to determine
    #   if the rule matches for a given model and request.
    # @yieldparam model [Object] The model being evaluated (e.g., a user or role).
    # @yieldparam request [Object] The request being evaluated (e.g., an HTTP request object).
    def initialize(type, &block)
      @type = type
      @rule = block
    end

    # Checks if the rule matches a given model and request.
    #
    # This method evaluates whether the provided model matches the rule's type
    # and if the rule's block returns `true` for the given model and request.
    #
    # @param model [Object] The model to check (e.g., a user or role).
    # @param request [Object] The request to check (e.g., an HTTP request object).
    # @return [Boolean] `true` if the model matches the rule's type and satisfies the block's logic, `false` otherwise.
    def matches?(model, request)
      rule.call(model, request)
    end
  end
end

