# frozen_string_literal: true

module Rails::Boost
  module Jbuilder
    module RenderPath
      # Render the JSON inside the block only if the given key is in the render
      # path specified by the template that rendered the partial.  E.g.:
      #
      # Parent template
      # ===============
      # json.partial!('wibbles', locals: {
      #   wibble: @wibble,
      #   render_path: { wibble: { foo: true } }
      # })
      #
      # Partial _wibbles.json.jbuilder
      # ==============================
      # json.href(wibbles_path(wibble))
      # json.auth(%i[read])
      # json.render_path!(:wibble) do
      #   json.something(wibble.something)  # => rendered
      #   json.render_path!(:foo, wibble.foo) do
      #     json.something(foo.something)  # => rendered
      #     json.render_path!(:bar, foo.bar) do
      #       json.something(bar.something)  # => not rendered
      #     end
      #   end
      # end
      def render_path!(target, value = nil)
        if _has_render_path_for?(target)
          _with_path_value(target, value) do
            _render_path_scope(render_path[target]) do
              merge!(_scope { yield })
            end
          end
        end
      end

      private

      attr_accessor :render_path
      # The context attribute is the ActionView::Base that is rendering the
      # template that instantiated this object.  The Jbuilder template handler
      # passes it to this object on initialization.
      attr_reader :context

      # This class uses this weird, underscore-first naming convention for
      # private methods because it is an ActiveSupport::ProxyObject.  It turns
      # all unknown method invocations into JSON elements.  On the extremely
      # unlikely chance that we may want a JSON element named "render_partial"
      # we avoid polluting the method namespace.
      #
      # Question mark and bang methods are also safe, but this is the convention
      # established by the original class, so we follow it.
      def _render_partial(options)
        locals = options[:locals]
        partial_render_path = locals.delete(:render_path) || render_path || {}
        _render_path_scope(partial_render_path) { super(options) }
      end

      def _has_render_path_for?(target)
        render_path.try(:has_key?, target) && render_path[target]
      end

      # rubocop:disable Metrics/MethodLength
      def _with_path_value(name, value)
        previous_method = nil
        context.singleton_class.instance_eval do
          previous_method = instance_method(name) if method_defined?(name)
          define_method(name) { value }
        end
        yield
      ensure
        context.singleton_class.instance_eval do
          undef_method(name)
          define_method(name, previous_method) if previous_method
        end
      end
      # rubocop:enable Metrics/MethodLength

      # This method mirrors the Jbuilder#_scope method.  This builder object
      # handles nesting by resetting its state as it enters each new block, and
      # restoring the original state as it exits the block.  This method follows
      # this pattern for the state of the render_path attribute.  The caller
      # passes in the new value of the attribute.
      def _render_path_scope(new_path)
        parent_render_path = render_path
        self.render_path = new_path
        yield
      ensure
        self.render_path = parent_render_path
      end
    end
  end
end

