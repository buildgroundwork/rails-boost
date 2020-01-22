# frozen_string_literal: true

module RailsImprovements
  class Railtie < Rails::Railtie
    initializer 'rails_improvements.action_controller.parameters' do
      require 'rails_improvements/action_controller/parameters'
    end
  end
end

