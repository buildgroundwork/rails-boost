# frozen_string_literal: true

require "rails/boost"
require "rails/boost/active_model/creation"
require "active_model"

RSpec.describe Rails::Boost::ActiveModel::Creation do
  before(:all) do
    ::ActiveModel.const_set(:Creation, described_class)

    klass = Class.new do
      include ActiveModel::Creation

      def initialize(foo: , bar: )
        @foo = foo; @bar = bar
      end
      attr_reader :foo, :bar
    end
    Object.const_set(:Thing, klass)
  end

  after(:all) { Object.instance_eval { remove_const(:Thing) } }

  describe "#create" do
    let(:foo) { 1 }
    let(:bar) { "wibble" }

    # rubocop:disable RSpec/MultipleExpectations
    it "allows creation of a model" do
      thing = Thing.create(foo: foo, bar: bar)
      expect(thing.foo).to be(foo)
      expect(thing.bar).to be(bar)
    end
    # rubocop:enable RSpec/MultipleExpectations
  end
end

