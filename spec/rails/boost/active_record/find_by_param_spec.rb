# frozen_string_literal: true

require "active_model"
require "active_record/relation/finder_methods"
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

class Relation
  def initialize(args) = @args = args

  attr_reader :args

  def take! = args
end

class Association
  include ActiveRecord::FinderMethods

  def model = Model
  def where(*args) = Relation.new(args)
end

class Model < ApplicationRecord
  url_param :my_param

  def my_param = "wibble"
  def my_association = Association.new
end

RSpec.describe Rails::Boost::ActiveRecord::FindByParam do
  describe ".find_by(param: )" do
    subject { target.find_by!(key => param) }
    let(:param) { "my-great-param" }

    context "on a model" do
      let(:target) { Model }

      context "with the `param` key" do
        let(:key) { :param }
        it { should == [{ my_param: param }] }
      end

      context "with a key other than `param`" do
        let(:key) { :foo }
        it { should == [{ key => param }] }
      end
    end

    context "on an association" do
      let(:target) { Model.new.my_association }

      context "with the `param` key" do
        let(:key) { :param }
        it { should == [{ my_param: param }] }
      end

      context "with a key other than `param`" do
        let(:key) { :foo }
        it { should == [{ key => param }] }
      end
    end
  end

  describe "#to_param" do
    subject { model.to_param }
    let(:model) { Model.new }
    it { should == model.my_param }
  end
end

