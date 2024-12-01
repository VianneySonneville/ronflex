# frozen_string_literal: true

require "ronflex/rule"
require "ronflex/errors"

# Module Ronflex
# 
# This module provides configuration to manage access rules based on templates and queries,
# with options to exclude certain paths or customize logic via a provider.
#
# @example Basic setup
#   Ronflex.configure do |config|
#     # add path to exclude all rule
#     config.excluded_path << "/public"

#     # add a provider to identify the model user
#     config.provider = ->(env) { env[:current_user] }

#     # add rule for administrator
#     config.add_rule(:admin) do |user, request|
#       # admins can access to all routes, expected "/restricted"
#       !request.path.start_with?("/restricted")
#     end

#     # add rule for guest
#     config.add_rule(:guest) do |user, request|
#       # guests can only acces public path
#       request.path.start_with?("/public")
#     end
#     
#     # add custom page maintenance
#     config.maintenance_page = "/path/to/your/custom/maintenance/page.html"
# end
module Ronflex
  class Configuration
    # List of paths excluded by default.
    # These paths are ignored by the defined rules.
    #
    # @return [Array<String>]
    DEFAULT_EXCLUDED_PATHS = ["/health_check", "/favicon.ico"]
    # Default provider.
    # by default, it is a lambda which returns `nil`.
    #
    # @return [Proc]
    DEFAULT_PROVIDER = -> (env) { nil }

    # Attribute for desable or enable th feature
    #
    # @return [Boolean]
    attr_accessor :enable

    # List of paths excluded from rule evaluation.
    #
    # @return [Array<String>]
    attr_accessor :excluded_path

    # Custom provider to retrieve a model based on the environment.
    #
    # @return [Proc]
    attr_accessor :provider

    # List of defined access rules.
    #
    # @return [Array<Rule>]
    attr_accessor :rules

    # Path to a custom maintenance page (either an HTML or ERB file).
    #
    # @return [String]
    attr_accessor :maintenance_page

    # Initializes a new configuration with default values.
    def initialize
      @excluded_path = DEFAULT_EXCLUDED_PATHS.dup
      @provider = DEFAULT_PROVIDER
      @enable = false
      @maintenance_page = nil
      @rules = []
    end
  
    # Adds an access rule for a specific type.
    #
    # A rule is a block of code that determines whether a model is allowed to access a given query.
    #
    # @param type [Symbol, String] The type or role of the model (e.g. `:admin`, `:user`).
    # @yield [model, request] The rule block, which takes a model and a request as parameters.
    # @yieldparam model [Object] The evaluated model.
    # @yieldparam request [Object] The evaluated request.
    # @return [void]
    #
    # @example Add a rule for administrators
    # config.add_rule(:admin) do |model, request|
    # request.path.start_with?("/admin")
    # end
    def add_rule(type, &block)
      raise RonflexArgumentError, "Rule type must be provided" if type.nil?
      raise RonflexArgumentError, "Block must be provided for the rule" unless block_given?
      @rules << Rule.new(type, &block)
    end
  
    # Checks if a model is allowed to access a given query.
    #
    # This method iterates through the defined rules and applies those matching the pattern.
    #
    # @param model [Object] The model to check (e.g. a user or a symbolic role).
    # @param request [Object] The request to check, which should respond to methods like `path`.
    # @return [Boolean] `true` if at least one rule authorizes access, `false` otherwise.
    #
    # @example Check an authorization
    # model = :admin
    # request = OpenStruct.new(path: "/admin/dashboard")
    # config.allowed?(model, request) # => true or false
    def allowed?(model, request)
      rules.empty? || rules.any? { |rule| rule.matches?(model, request) }
    end


    # Checks if a model is valid (present).
    #
    # @param model [Object] The model to check.
    # @return [Boolean] `true` if the model is valid, `false` otherwise.
    #
    # @note This method uses the `present?` method, which is typically available in Rails.
    # If you are not using Rails, you may need to override this method.
    def model_present?(model)
      !model.nil? && !(model.respond_to?(:empty?) && model.empty?)
    end
  end
end
