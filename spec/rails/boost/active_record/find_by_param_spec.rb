# frozen_string_literal: true

require "active_model"
require "rails/boost"
require "rails/boost/active_record/find_by_param"

module Finders
  def find_by!(*args) = args
end

class ApplicationRecord
  include ActiveModel::Model

  extend Finders
  extend Rails::Boost::ActiveRecord::FindByParam
end

class Model < ApplicationRecord
  url_param :my_param

  def my_param = "wibble"
end

RSpec.describe Rails::Boost::ActiveRecord::FindByParam do
  describe ".find_by(param: )" do
    subject { Model.find_by!(key => param) }
    let(:param) { "my-great-param" }

    context "with the `param` key" do
      let(:key) { :param }
      it { should == [{ my_param: param }] }
    end

    context "with a key other than `param`" do
      let(:key) { :foo }
      it { should == [{ key => param }] }
    end
  end

  describe "#to_param" do
    subject { model.to_param }
    let(:model) { Model.new }
    it { should == model.my_param }
  end
end

