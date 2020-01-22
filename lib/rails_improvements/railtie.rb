# frozen_string_literal: true

module RailsImprovements
  class Railtie < Rails::Railtie
    initializer 'rails_improvements.action_controller.parameters.hash_polymorphism' do
      require 'rails_improvements/action_controller/parameters/hash_polymorphism'
      ::ActionController::Parameters.instance_eval do
        include RailsImprovements::ActionController::Parameters::HashPolymorphism
      end
    end

    initializer 'rails_improvements.active_record.named_parameters', after: 'active_record' do
      require 'rails_improvements/active_record/named_parameters'
      ::ActiveRecord::Base.instance_eval do
        prepend RailsImprovements::ActiveRecord::NamedParameters
      end
    end
  end
end

