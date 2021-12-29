# frozen_string_literal: true

require "jbuilder"
require "action_view/testing/resolvers"
ActionView::Template.register_template_handler :jbuilder, JbuilderHandler

module Jbuilder::TestRender
  def render(source, partials: {})
    view = build_view(fixtures: partials.merge("source.json.jbuilder" => source))
    view.render(template: "source")
  end

  def build_view(fixtures: )
    resolver = ActionView::FixtureResolver.new(fixtures)
    lookup_context = ActionView::LookupContext.new([resolver], {}, [""])
    controller = ActionView::TestCase::TestController.new

    ActionView::Base.with_empty_template_cache.new(lookup_context, {}, controller)
  end
end

