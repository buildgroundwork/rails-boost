# frozen_string_literal: true

module Rails::Improvements
  class Railtie < Rails::Railtie
    initializer 'rails-improvements.action_controller.parameters.hash_polymorphism' do
      require 'rails/improvements/action_controller/parameters/hash_polymorphism'
      ::ActionController::Parameters.instance_eval do
        include Rails::Improvements::ActionController::Parameters::HashPolymorphism
      end
    end

    initializer 'rails-improvements.active_record.named_parameters', after: 'active_record' do
      require 'rails/improvements/active_record/named_parameters'
      ::ActiveRecord::Base.instance_eval do
        prepend Rails::Improvements::ActiveRecord::NamedParameters
      end
    end

    initializer 'rails-improvements.active_record.active_storage_keys', after: 'active_record' do
      require 'rails/improvements/active_record/active_storage_keys'
      ::ActiveRecord::Base.singleton_class.instance_eval do
        prepend Rails::Improvements::ActiveRecord::ActiveStorageKeys
      end
    end

    initializer 'rails-improvements.active_storage.blob.sensible_key' do
      require 'rails/improvements/active_storage/blob/sensible_key'

      ActiveSupport.on_load(:active_storage_blob) do
        ::ActiveStorage::Blob.instance_eval do
          prepend Rails::Improvements::ActiveStorage::Blob::SensibleKey
        end
      end
    end

    initializer 'rails-improvements.active_support.hash_with_indifferent_access.opinionated_keys', after: 'active_support' do
      require 'rails/improvements/active_support/hash_with_indifferent_access/opinionated_keys'

      ::ActiveSupport::HashWithIndifferentAccess.instance_eval do
        prepend Rails::Improvements::ActiveSupport::HashWithIndifferentAccess::OpinionatedKeys
      end
    end

    rake_tasks do
      load 'rails/improvements/tasks/db.rake'
    end
  end
end

