# frozen_string_literal: true

module Rails::Boost
  module ActiveRecord
    module FindByParam
      def find_by_param!(param)
        find_by!(id: param)
      end
    end
  end
end

