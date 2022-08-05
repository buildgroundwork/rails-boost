# frozen_string_literal: true

require "active_support/concern"

# Including this module into a non-AR model will add the .create and #save
# methods, thus making it polymorphic with ActiveRecord in this regard.
#
# This is useful for non-AR resource models, so controller can call .create
# without worrying about the underlying model class hierarchy.
module Rails::Boost
  module ActiveModel
    module Creation
      extend ActiveSupport::Concern

      module ClassMethods
        def create(...)
          new(...).tap(&:save)
        end
      end

      def save; end
    end
  end
end

