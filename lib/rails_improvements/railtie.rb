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

    initializer 'rails_improvements.active_record.active_storage_keys', after: 'active_record' do
      require 'rails_improvements/active_record/active_storage_keys'
      ::ActiveRecord::Base.singleton_class.instance_eval do
        prepend RailsImprovements::ActiveRecord::ActiveStorageKeys
      end
    end

    initializer 'rails_improvements.active_storage.blob.sensible_key' do
      require 'rails_improvements/active_storage/blob/sensible_key'

      ActiveSupport.on_load(:active_storage_blob) do
        ::ActiveStorage::Blob.instance_eval do
          prepend RailsImprovements::ActiveStorage::Blob::SensibleKey
        end
      end
    end

    rake_tasks do
      load 'rails_improvements/tasks/db.rake'
    end
  end
end

