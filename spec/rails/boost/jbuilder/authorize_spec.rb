# frozen_string_literal: true

require "jbuilder_helper"
require "rails/boost/jbuilder/authorize"
require "pundit"

RSpec.describe Rails::Boost::Jbuilder::Authorize do
  include Jbuilder::TestRender

  before(:all) do
    mod = described_class
    JbuilderTemplate.instance_eval { prepend mod }
    Jbuilder.extend(Rails::Boost::Jbuilder::Authorizer)
  end

  describe "#render" do
    subject { render(source, assigns: { resource: }, current_user:) }
    let(:source) { %[json.authorize!(@resource)] }
    let(:resource) { Object.new }

    context "when authorized with Pundit" do
      before do
        Jbuilder.authorize_with(:pundit)
        resource.singleton_class.instance_eval { define_method(:policy_class) { APolicy } }
      end

      context "with no block given" do
        Rails::Boost::Jbuilder::Authorize::ACTIONS.each do |action|
          context "with a user with only #{action} authorization" do
            let(:current_user) { "can #{action}" }
            it { should have_json_element(:auth).with_value(%W[#{action}]) }
          end
        end

        context "with a user with authorization for any action" do
          let(:current_user) { "admin" }

          context "when restricted to only one action" do
            let(:source) { %[json.authorize!(@resource, only: :read)] }
            it { should have_json_element(:auth).with_value(%w[read]) }
          end

          context "when restricted to multiple actions" do
            let(:source) { %[json.authorize!(@resource, only: %w[read update])] }
            it { should have_json_element(:auth).with_value(%w[read update]) }
          end

          context "when not restricted" do
            it { should have_json_element(:auth).with_value(%w[create read update destroy]) }
          end
        end

        context "with a user with authorization for no actions" do
          let(:current_user) { "cannot!" }
          it { should_not have_json_element(:auth) }
        end
      end

      context "with a block given" do
        let(:source) { <<~SOURCE }
          json.authorize!(@resource) do
            json.wibble(1)
          end
        SOURCE

        context "with a user with authorization for any action" do
          let(:current_user) { "can read" }
          it { should have_json_element(:auth).with_value(%w[read]) }
          it { should have_json_element(:wibble).with_value(1) }
        end

        context "with a user with authorization for no actions" do
          let(:current_user) { "cannot!" }
          it { should_not have_json_element(:auth) }
          it { should_not have_json_element(:wibble) }
        end
      end

      context "when authorizing a collection" do
        let(:source) { %[json.authorize_collection!(@resource)] }

        context "with a user with only index authorization" do
          let(:current_user) { "can index" }
          it { should have_json_element(:auth).with_value(%w[read]) }
        end

        context "with a user with authorization for any action" do
          let(:current_user) { "admin" }

          context "when restricted to only one action" do
            let(:source) { %[json.authorize_collection!(@resource, only: :read)] }
            it { should have_json_element(:auth).with_value(%w[read]) }
          end

          context "when not restricted" do
            it { should have_json_element(:auth).with_value(%w[create read]) }
          end
        end
      end
    end

    context "when authorized with a custom authorizer" do
      let(:authorizer) { Authorizer.new(action) }
      let(:current_user) { "a user" }
      before { Jbuilder.authorize_with(AnAuthorizer) }

      Rails::Boost::Jbuilder::Authorize::ACTIONS.each do |action|
        context "with a resource with only #{action} authorization" do
          let(:current_user) { "can #{action}" }
          it { should have_json_element(:auth).with_value(%W[#{action}]) }
        end
      end

      context "with a user with authorization for any action" do
        let(:current_user) { "admin" }
        it { should have_json_element(:auth).with_value(%w[create read update destroy]) }
      end
    end
  end
end

class APolicy
  def initialize(user, *)
    @user = user
  end

  attr_reader :user

  def index?
    user == "admin" || user == "can index"
  end

  def show?
    user == "admin" || user == "can read"
  end

  def create?
    user == "admin" || user == "can create"
  end

  def update?
    user == "admin" || user == "can update"
  end

  def destroy?
    user == "admin" || user == "can destroy"
  end
end

class AnAuthorizer
  def initialize(...)
    @policy = APolicy.new(...)
  end

  attr_reader :policy

  delegate :create?, :update?, :destroy?, to: :policy

  def read?
    policy.show?
  end
end

