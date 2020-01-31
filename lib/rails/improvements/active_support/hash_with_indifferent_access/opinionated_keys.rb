# frozen_string_literal: true

# HashWithIndifferentAccess is, by its nature, indifferent to how you reference
# keys, so there's no good reason to use strings vs. symbols as keys.  Given
# that Ruby has clearly chosen symbols as the preferred type of hash key, and
# Ruby functionality such as named parameters are the ** operator require that
# keys be symbols, HWIA should play nicely with the rest of the Ruby ecosystem.
module Rails::Improvements
  module ActiveSupport
    module HashWithIndifferentAccess
      module OpinionatedKeys
        def transform_keys!
          return enum_for(:transform_keys!) { size } unless block_given?
          keys.each { |key| self[yield(key.to_s)] = delete(key) }
          self
        end

        private

        def convert_key(key)
          key.to_sym
        end
      end
    end
  end
end

