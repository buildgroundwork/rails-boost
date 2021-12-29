# frozen_string_literal: true

require "jbuilder"
require "action_view/testing/resolvers"
require "rails/boost/jbuilder/render_path"
require "rspec/common/matchers"

ActionView::Template.register_template_handler :jbuilder, JbuilderHandler

WITHOUT_RENDER_PATH = <<~JBUILDER
  json.without(1)
JBUILDER

WITH_RENDER_PATH = <<~JBUILDER
  json.with(1)
  json.render_path!(:without_render_path) do
    json.partial!("without_render_path")
  end
JBUILDER

DEEPLY_NESTED = <<~JBUILDER
  json.render_path!(:with_render_path) do
    json.partial!("with_render_path")
  end
JBUILDER

PARTIALS = {
  "_with_render_path.json.jbuilder" => WITH_RENDER_PATH,
  "_without_render_path.json.jbuilder" => WITHOUT_RENDER_PATH,
  "_deeply_nested.json.jbuilder" => DEEPLY_NESTED
}.freeze

RSpec.describe Rails::Boost::Jbuilder::RenderPath do
  before { ::JbuilderTemplate.instance_eval { prepend ::Rails::Boost::Jbuilder::RenderPath } }

  describe "#render" do
    subject { render(source) }

    context "with a partial that contains no nested blocks" do
      let(:source) { %[json.partial!("without_render_path")] }
      it { should have_json_element(:without) }
    end

    context "with a partial that contains a nested block" do
      let(:source) { %[json.partial!("with_render_path", render_path: #{render_path})] }

      context "with the render path for the nested block" do
        let(:render_path) { { without_render_path: true } }
        it { should have_json_element(:with) }
        it { should have_json_element(:without) }
      end

      context "without the render path for the nested block" do
        let(:render_path) { {} }
        it { should have_json_element(:with) }
        it { should_not have_json_element(:without) }
      end

      context "with a nonsense render path" do
        let(:render_path) { { wibble: true } }
        it { should have_json_element(:with) }
        it { should_not have_json_element(:without) }
      end
    end

    context "with deeply nested blocks" do
      let(:source) { %[json.partial!("deeply_nested", render_path: #{render_path})] }

      context "with the render path for all levels" do
        let(:render_path) { { with_render_path: { without_render_path: true } } }
        it { should have_json_element(:with) }
        it { should have_json_element(:without) }
      end

      context "with the render path for only the top level nesting" do
        let(:render_path) { { with_render_path: true } }
        it { should have_json_element(:with) }
        it { should_not have_json_element(:without) }
      end
    end
  end

  private

  def render(source)
    view = build_view(fixtures: PARTIALS.merge("source.json.jbuilder" => source))
    view.render(template: "source")
  end

  def build_view(fixtures: )
    resolver = ActionView::FixtureResolver.new(fixtures)
    lookup_context = ActionView::LookupContext.new([resolver], {}, [""])
    controller = ActionView::TestCase::TestController.new

    ActionView::Base.with_empty_template_cache.new(lookup_context, {}, controller)
  end
end

