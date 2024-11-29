# frozen_string_literal: true

require "ronflex/rest"

module Ronflex
  class Railtie < Rails::Railtie
    initializer "ronflex.configure_rails_initialization" do |app|
      app.middleware.insert_before 0, Ronflex::Rest
    end
  end
end
