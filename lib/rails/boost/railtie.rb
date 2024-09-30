# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
module Rails::Boost
  class Railtie < Rails::Railtie
    initializer "rails-boost.active_model.creation" do
      require "rails/boost/active_model/creation"
      ::ActiveModel.const_set(:Creation, Rails::Boost::ActiveModel::Creation)
    end

    initializer "rails-boost.action_controller.parameters.acceptable" do
      require "rails/boost/action_controller/parameters/acceptable"
      ::ActionController::Parameters.instance_eval do
        include Rails::Boost::ActionController::Parameters::Acceptable
      end
    end

    initializer "rails-boost.action_controller.parameters.hash_polymorphism" do
      require "rails/boost/action_controller/parameters/hash_polymorphism"
      ::ActionController::Parameters.instance_eval do
        include Rails::Boost::ActionController::Parameters::HashPolymorphism
      end
    end

    initializer "rails-boost.action_controller.params_wrapper" do
      require "rails/boost/action_controller/params_wrapper"
      ::ActionController::ParamsWrapper.instance_eval do
        include Rails::Boost::ActionController::ParamsWrapper
      end
    end

    initializer "rails-boost.action_controller.transform_request_keys" do
      require "rails/boost/action_controller/transform_request_keys"
      ::ActionController::Base.instance_eval do
        prepend Rails::Boost::ActionController::TransformRequestKeys
      end
    end

    initializer "rails-boost.active_record.find_by_param" do
      require "rails/boost/active_record/find_by_param"
      ::ActiveSupport.on_load(:active_record) do
        extend(Rails::Boost::ActiveRecord::FindByParam)
      end
    end

    initializer "rails-boost.active_record.named_parameters" do
      require "rails/boost/active_record/named_parameters"
      ::ActiveSupport.on_load(:active_record) do
        prepend Rails::Boost::ActiveRecord::NamedParameters
      end
    end

    initializer "rails-boost.active_record.active_storage_keys" do
      require "rails/boost/active_record/active_storage_keys"
      ::ActiveSupport.on_load(:active_record) do
        singleton_class.instance_eval do
          prepend Rails::Boost::ActiveRecord::ActiveStorageKeys
        end
      end
    end

    initializer "rails-boost.active_record.types.set" do
      require "rails/boost/active_record/type/set"
      ::ActiveSupport.on_load(:active_record) do
        ::ActiveRecord::Type.register(:set, Rails::Boost::ActiveRecord::Type::Set)
      end
    end

    initializer "rails-boost.active_storage.blob.sensible_key" do
      require "rails/boost/active_storage/blob/sensible_key"

      ActiveSupport.on_load(:active_storage_blob) do
        ::ActiveStorage::Blob.instance_eval do
          prepend Rails::Boost::ActiveStorage::Blob::SensibleKey
        end
      end
    end

    if Object.const_defined?(:Aws) && Aws.const_defined?(:S3)
      initializer "rails-boost.active_storage.content_encoding" do
        require "rails/boost/active_storage/blob/content_encoding"
        require "rails/boost/active_storage/service/s3_service/content_encoding"

        ActiveSupport.on_load(:active_storage_blob) do
          ::ActiveStorage::Blob.instance_eval do
            prepend Rails::Boost::ActiveStorage::Blob::ContentEncoding
          end

          ::ActiveStorage::Service::S3Service.instance_eval do
            prepend Rails::Boost::ActiveStorage::Service::S3Service::ContentEncoding
          end
        end
      end
    end

    initializer "rails-boost.active_support.hash_with_indifferent_access.opinionated_keys", after: "load_active_support" do
      require "rails/boost/active_support/hash_with_indifferent_access/opinionated_keys"
      ::ActiveSupport::HashWithIndifferentAccess.instance_eval do
        prepend Rails::Boost::ActiveSupport::HashWithIndifferentAccess::OpinionatedKeys
      end
    end

    initializer "rails-boost.active_job.optional_callbacks" do
      require "rails/boost/active_job/optional_callbacks"
      ::ActiveJob::Base.instance_eval do
        prepend Rails::Boost::ActiveJob::OptionalCallbacks
      end
    end

    initializer "rails-boost.action_dispatch.routing.canonical_host" do
      require "rails/boost/action_dispatch/routing/canonical_host"
      ::ActionDispatch::Routing::Mapper.instance_eval do
        include Rails::Boost::ActionDispatch::Routing::CanonicalHost
      end
    end

    initializer "rails-boost.action_dispatch.routing.route_set" do
      require "rails/boost/action_dispatch/routing/route_set"
      ::ActionDispatch::Routing::RouteSet.instance_eval do
        include Rails::Boost::ActionDispatch::Routing::RouteSet::AsJson
      end
    end

    # rubocop:disable Lint/SuppressedException, Style/MethodCallWithArgsParentheses
    begin
      require "jbuilder"

      initializer "rails-boost.jbuilder.render_path" do
        require "rails/boost/jbuilder/render_path"
        ::JbuilderTemplate.instance_eval { prepend Jbuilder::RenderPath }
      end

      initializer "rails-boost.jbuilder.authorize" do
        require "rails/boost/jbuilder/authorize"
        ::JbuilderTemplate.instance_eval { prepend Jbuilder::Authorize }
        ::Jbuilder.extend Jbuilder::Authorizer
      end
    rescue LoadError
    end
    # rubocop:enable Lint/SuppressedException, Style/MethodCallWithArgsParentheses

    rake_tasks do
      load "rails/boost/tasks/db.rake"
    end
  end
end
# rubocop:enable Metrics/ClassLength

