# frozen_string_literal: true

# ActiveRecord's initalizer expects an object that it can treat as a hash.
# This disallows using keyword arguments, because the initializer parameter
# list expects exactly one parameter, rather than named parameters.
#
# This change will allow passing named parameters or (until Ruby 2.7) a hash
# that will be implicitly converted to named parameters.
#
# In Ruby 2.7 implicit conversion from a hash to named parameters will
# become a warning, so this will require an explicit double splat.
module RailsImprovements
  module ActiveRecord
    module NamedParameters
      def initialize(**named)
        named.empty? ? super : super(named)
      end
    end
  end
end

