# frozen_string_literal: true

# This object *should* behave polymorphically with a Hash object (which it
# stands in for).  You can see the conversation about the change that broke
# this behavior here: `https://github.com/rails/rails/pull/14384`.
# The change to Rails did solve a security hole, but unfortunately broke the
# polymorphic interface in doing so.  This fix restores the interface without
# affecting the security fix.
module RailsImprovements
  module ActionController
    module Parameters
      module HashPolymorphism
        def method_missing(method, *args, &block)
          h = to_h
          h.respond_to?(method) ? h.public_send(method, *args, &block) : super
        end

        def respond_to_missing?(method, *args)
          super || Hash.public_method_defined?(method)
        end
      end
    end
  end
end

