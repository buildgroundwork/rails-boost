# frozen_string_literal: true

module RailsImprovements
  class Railtie < Rails::Railtie
    initializer 'rails_improvements.action_controller.parameters.hash_polymorphism' do
      require 'rails_improvements/action_controller/parameters/hash_polymorphism'
      ActionController::Parameters.instance_eval do
        include RailsImprovements::ActionController::Parameters::HashPolymorphism
      end
    end
  end
end

