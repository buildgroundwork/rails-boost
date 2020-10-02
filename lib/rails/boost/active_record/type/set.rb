# frozen_string_literal: true

require "active_record"

module Rails::Boost
  module ActiveRecord
    module Type
      class Set < ::ActiveRecord::Type::Value
        def serialize(set)
          set&.sort
        end

        def cast(input)
          input && ::Set.new(input)
        end
      end
    end
  end
end

