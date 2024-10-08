# frozen_string_literal: true

module Rails::Boost
  module ActiveRecord
    module FindByParam
      def url_param(url_param_name)
        @url_param_name = url_param_name
        define_method(:to_param) { public_send(url_param_name) }
      end

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

      attr_reader :url_param_name

      def extract_param(args)
        args.first.is_a?(Hash) && args.first.one? && args.first.keys.first == :param &&
          args.first.values.first
      end
    end
  end
end

