# frozen_string_literal: true

require "active_record/relation/finder_methods"

module Rails::Boost
  module ActiveRecord
    module FindByParam
      module Finders
        def find_by!(*args)
          if (param = extract_param(args))
            key = url_param_name || :id
            super(key => param)
          else
            super
          end
        end

        def find_by_param!(param)
          ActiveSupport::Deprecation.new.warn(<<~MSG)
            The #find_by_param! method has been deprecated.
            Use the `url_param` and `find_by!(param:) class methods instead.
          MSG
          find_by!(id: param)
        end

        private

        def extract_param(args)
          args.first.is_a?(Hash) && args.first.one? && args.first.keys.first == :param &&
            args.first.values.first
        end
      end

      module AssocationUrlParamName
        delegate :url_param_name, to: :model
      end

      class << self
        def extended(klass)
          klass.extend(Finders)

          mod = ::ActiveRecord.const_defined?(:FinderMethods) && ::ActiveRecord.const_get(:FinderMethods)
          mod.prepend(Finders)
          mod.include(AssocationUrlParamName)
        end
      end

      def url_param(url_param_name)
        @url_param_name = url_param_name
        define_method(:to_param) { public_send(url_param_name) }
      end

      attr_reader :url_param_name
    end
  end
end

