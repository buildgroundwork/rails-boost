# frozen_string_literal: true

module Rails::Boost
  module ActionDispatch
    module Routing
      module RouteSet
        module AsJson
          def as_json(*args, include_rails: false, include_format: false, **kwargs)
            paths = route_paths
            paths = paths.reject { |route| route.name.include?("rails") } unless include_rails
            paths.to_h { |route| [json_name(route), json_path(route, include_format: include_format)] }.as_json(*args, **kwargs)
          end

          private

          def route_paths
            routes
              .collect { |route| ::ActionDispatch::Routing::RouteWrapper.new(route) }
              .reject { |route| route.name.empty? }
          end

          def json_name(route)
            "#{route.name.camelize(:lower)}Path"
          end

          def json_path(route, include_format: )
            path = route.path
            path = path.sub(/\(.*\)/, "") unless include_format
            path
              .scan(%r{(:[^/]+)})
              .inject(path) do |result, tokens|
                token = tokens.first
                result.sub(token, token.camelize)
              end
          end
        end
      end
    end
  end
end

