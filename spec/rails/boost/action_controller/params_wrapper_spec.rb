# frozen_string_literal: true

require "action_controller"
require "rails/boost/action_controller/params_wrapper"

class Wibble
  class << self
    def attribute_names
      %i[foo bar]
    end
  end
end

class ApplicationController < ActionController::Base
  class << self
    def name
      "WibblesController"
    end
  end
end

RSpec.describe Rails::Boost::ActionController::ParamsWrapper do
  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    ::ActionController::ParamsWrapper.instance_eval do
      include ::Rails::Boost::ActionController::ParamsWrapper
    end
  end

  describe "._wrapper_options" do
    subject { controller_class._wrapper_options }

    context "with no wrapper key" do
      let(:controller_class) { Class.new(ApplicationController) { wrap_parameters format: %i[json] } }
      its(:name) { should == "wibble" }
      its(:include) { should be_nil }
      its(:exclude) { should be_nil }
      its(:model) { should be_nil }
    end

    context "with only a wrapper key" do
      let(:controller_class) { Class.new(ApplicationController) { wrap_parameters :foozle } }
      its(:name) { should == :foozle }
      its(:include) { should be_nil }
      its(:exclude) { should be_nil }
      its(:model) { should be_nil }
    end

    context "with a list of parameters to include" do
      let(:controller_class) { Class.new(ApplicationController) { wrap_parameters include: %i[sally] } }
      its(:name) { should == "wibble" }
      its(:include) { should == %w[sally] }
      its(:exclude) { should be_nil }
      its(:model) { should be_nil }
    end

    context "with a wrapper key and a list of parameters to include" do
      let(:controller_class) { Class.new(ApplicationController) { wrap_parameters :foozle, include: %i[sally] } }
      its(:name) { should == :foozle }
      its(:include) { should == %w[sally] }
      its(:exclude) { should be_nil }
      its(:model) { should be_nil }
    end

    context "with a list of parameters to exclude" do
      let(:controller_class) { Class.new(ApplicationController) { wrap_parameters exclude: %i[jeff] } }
      its(:name) { should == "wibble" }
      its(:include) { should be_nil }
      its(:exclude) { should == %w[jeff] }
      its(:model) { should be_nil }
    end
  end
end

