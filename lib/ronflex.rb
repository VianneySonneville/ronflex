# frozen_string_literal: true

require_relative "ronflex/version"
require "ronflex/configuration"

module Ronflex  
  class << self
    # Method to configure `Snorlax` with a block
    #
    # @yield [config] The block receives an instance of `Snorlax::Configuration`
    # @yieldparam config [Snorlax::Configuration] The configuration object to modify.
    def configure
      @configuration ||= Configuration.new
      yield @configuration if block_given?
    end

    # Accesses global configuration
    #
    # @return [Snorlax::Configuration] The global instance of the configuration
    def configuration
      @configuration ||= Configuration.new
    end

    # Simulates playing the Pokéflute, disabling a feature.
    #
    # This method modifies the global configuration to enable a specific feature.
    #
    # @return [void]
    def play_pokeflute
      configuration.enable = false
    end

    # Simulates stopping the Pokéflute, enabling a feature.
    #
    # This method modifies the global configuration to disable a specific feature.
    #
    # @return [void]
    def stop_pokeflute
      configuration.enable = true
    end
  end
end
