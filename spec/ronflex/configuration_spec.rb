# frozen_string_literal: true
#
# spec/ronflex/configuration_spec.rb
require 'spec_helper'
require 'ronflex/configuration'

RSpec.describe Ronflex::Configuration do
  let(:configuration) { described_class.new }

  describe '#initialize' do
    it 'sets default excluded_path' do
      expect(configuration.excluded_path).to eq(["/health_check"])
    end

    it 'sets default provider' do
      expect(configuration.provider).to be_a(Proc)
    end

    it 'sets default enable to true' do
      expect(configuration.enable).to eq(false)
    end
  end

  describe '#add_rule' do
    it 'adds a rule to the rules array' do
      rule_block = ->(model, request) { true }
      configuration.add_rule(:admin, &rule_block)

      expect(configuration.rules.size).to eq(1)
      expect(configuration.rules.first.type).to eq(:admin)
    end
  end

  describe '#allowed?' do
    it 'returns true if the rule matches' do
      rule_block = ->(model, request) { model == :admin }
      configuration.add_rule(:admin, &rule_block)
      
      expect(configuration.allowed?(:admin, double)).to eq(true)
    end

    it 'returns false if the rule does not match' do
      rule_block = ->(model, request) { model == :user }
      configuration.add_rule(:admin, &rule_block)

      expect(configuration.allowed?(:user, double)).to eq(false)
    end
  end
end
