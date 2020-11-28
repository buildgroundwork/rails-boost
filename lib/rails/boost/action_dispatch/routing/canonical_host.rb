# frozen_string_literal: true

module Rails::Boost
  module ActionDispatch
    module Routing
      module CanonicalHost
        def enforce_canonical_host
          return unless canonical_hostname

          constraints(host: Regexp.new("^(?!#{Regexp.escape(canonical_hostname)})")) do
            match("/(*path)" => redirect { |params, _req| "https://#{canonical_hostname}/#{params[:path]}" }, via: %i[get post])
          end
        end

        def canonical_hostname
          @canonical_hostname ||= ENV["CANONICAL_HOST"]
        end
      end
    end
  end
end

