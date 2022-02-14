# frozen_string_literal: true

require "jbuilder"
require "pundit"
require "action_view/testing/resolvers"
ActionView::Template.register_template_handler :jbuilder, JbuilderHandler

module Jbuilder::TestRender
  def render(source, partials: {}, **kwargs)
    view = build_view(fixtures: partials.merge("source.json.jbuilder" => source), **kwargs)
    view.render(template: "source")
  end

  def build_view(fixtures: , assigns: {}, current_user: nil)
    resolver = ActionView::FixtureResolver.new(fixtures)
    lookup_context = ActionView::LookupContext.new([resolver], {}, [""])
    controller = ActionView::TestCase::TestController.new

    ActionView::Base.with_empty_template_cache.new(lookup_context, assigns, controller).tap do |view|
      view.singleton_class.instance_eval do
        include Pundit::Authorization
        define_method(:current_user) { current_user }
      end
    end
  end
end

