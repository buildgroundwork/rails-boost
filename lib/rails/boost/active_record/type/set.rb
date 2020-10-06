# frozen_string_literal: true

require "active_record"
require "active_record/connection_adapters/postgresql/oid/array"

module Rails::Boost
  module ActiveRecord
    module Type
      class Set
        def initialize(array_type)
          @array_type = array_type
        end

        def serialize(set)
          if set&.respond_to?(:to_a)
            array_type.serialize(array_type.cast(set.to_a).uniq.sort)
          else
            array_type.serialize(set)
          end
        end

        def deserialize(...)
          cast(array_type.deserialize(...))
        end

        def cast(input)
          if input.is_a?(Array)
            input && ::Set.new(array_type.cast(input))
          else
            input
          end
        end

        delegate_missing_to :array_type

        private

        attr_reader :array_type
      end
    end
  end
end

