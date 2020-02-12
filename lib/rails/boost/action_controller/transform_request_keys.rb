# frozen_string_literal: true

module Rails::Boost
  module ActionController
    module TransformRequestKeys
      def process_action(*args)
        request.request_parameters.deep_transform_keys!(&:underscore)
        super
      end
    end
  end
end

