# frozen_string_literal: true

# HashWithIndifferentAccess is, by its nature, indifferent to how you reference
# keys.  However, Ruby has clearly chosen symbols as the preferred type of hash
# key, and Ruby functionality such as named parameters and the ** operator
# require that keys be symbols.  HWIA should play nicely with the rest of the
# Ruby ecosystem, so this will convert all keys to symbols when converting the
# HWIA to a Hash.
module Rails::Boost
  module ActiveSupport
    # This is not a reference to top-level HWIA
    # rubocop:disable Rails/TopLevelHashWithIndifferentAccess
    module HashWithIndifferentAccess
      module OpinionatedKeys
        def to_hash
          super.deep_symbolize_keys
        end

        def deep_transform_keys
          super.with_indifferent_access
        end
      end
    end
    # rubocop:enable Rails/TopLevelHashWithIndifferentAccess
  end
end

