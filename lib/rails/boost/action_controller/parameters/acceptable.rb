# frozen_string_literal: true

# ActionController::Parameters#require will raise a BadRequest exception for a
# key that is not present.  Some resources don't require any parameters, and
# the hash root will be removed by the ActionController parameter processing if
# it contains no values.
#
# This method is more permissive.  If the specified root exists it behaves the
# same as #require; if not, it returns an empty Parameters object rather than
# raising an exception.
module Rails::Boost
  module ActionController
    module Parameters
      module Acceptable
        def accept(key)
          self[key] || ::ActionController::Parameters.new
        end
      end
    end
  end
end

