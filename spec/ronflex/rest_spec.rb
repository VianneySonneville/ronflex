# frozen_string_literal: true
#
# spec/ronflex/rest_spec.rb
require 'spec_helper'

RSpec.describe Ronflex::Rest do
  let(:app) { double("App") } # Utilisez un double pour simuler l'application rack
  let(:env) { {} } # Un hash vide comme environnement pour commencer
  let(:rest) { described_class.new(app) }

  describe '#call' do
    context 'when always_access? is true' do
      it 'returns the original app call without restrictions' do
        allow(rest).to receive(:always_access?).and_return(true)
        expect(app).to receive(:call).with(env)
        
        rest.call(env)
      end
    end

    context 'when always_access? is false and maintenance mode is enabled' do
      it 'returns the maintenance page when model is not authorized' do
        allow(rest).to receive(:always_access?).and_return(false)
        allow(Ronflex.configuration).to receive(:enable).and_return(true)
        allow(rest).to receive(:model_present?).and_return(false)
        allow(rest).to receive(:routes_authorized?).and_return(false)
        
        response = rest.call(env)

        expect(response).to eq([503, { "Content-Type" => "text/html" }, [rest.send(:maintenance_page)]])
      end
    end
  end
end
