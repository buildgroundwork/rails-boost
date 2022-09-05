# frozen_string_literal: true

module Rails::Boost
  module Jbuilder
    module Authorize
      # Insert an `auth` key into the JSON that enumerates actions the current
      # user is authorized to perform on the given resource.  E.g.:
      #
      # Template wibble.json.jbuilder
      # =============================
      # json.authorize!(@wibble) => { auth: ['read', 'update'] }
      #
      # OR
      #
      # json.authorize!(@wibble, only: :read) => { auth: ['read'] }
      #
      # This will use the current user, and the policy object associated with
      # the resource (if using Pundit), or a custom authorizer object provided
      # at initialization.
      #
      # Using Pundit
      # ============
      # In config/initializers/jbuilder.rb):
      #   Jbuilder.authorize_with(:pundit)
      #
      # Not using Pundit
      # ================
      # In config/initializers/jbuilder.rb):
      #   Jbuilder.authorize_with(MyCustomAuthorizer)
      #
      # Your custom authorizer class's initializer should accept current_user
      # and resource as positional parameters, and expose methods for each of
      # the four CRUD actions.  E.g.:
      #
      # class MyCustomAuthorizer
      #   def initialize(current_user, resource)
      #     ...
      #   end
      #
      #   def create?
      #     ...
      #   end
      #
      #   def read?
      #    ...
      #   end
      #
      #   def update?
      #     ...
      #   end
      #
      #   def destroy?
      #     ...
      #   end
      # end
      ACTIONS = %i[create read update destroy].freeze

      def authorize!(resource, only: ACTIONS)
        authorizer = _authorizer_for(resource)
        set!(:auth, [*only].select { |action| authorizer.public_send(:"#{action}?") })
      end
    end

    module Authorizer
      def authorize_with(authorizer)
        mod = authorizer == :pundit ? PunditAuthorizer : CustomAuthorizer.new(authorizer)
        Authorize.instance_eval { include(mod) }
      end

      module PunditAuthorizer
        def _authorizer_for(resource)
          PunditAdapter.new(@context.__send__(:policy, resource))
        end

        class PunditAdapter
          def initialize(policy)
            @policy = policy
          end

          delegate :create?, :update?, :destroy?, to: :policy

          def read?
            policy.show?
          end

          attr_reader :policy
        end
      end

      class CustomAuthorizer < Module
        def initialize(authorizer_class)
          super()

          define_method(:_authorizer_for) do |resource|
            authorizer_class.new(@context.current_user, resource)
          end
        end
      end
    end
  end
end

