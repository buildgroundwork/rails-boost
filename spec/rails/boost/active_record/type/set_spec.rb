# frozen_string_literal: true

require "rails/boost"
require "rails/boost/active_record/type/set"

RSpec.describe Rails::Boost::ActiveRecord::Type::Set do
  let(:type) { described_class.new }

  describe "#cast" do
    subject { type.cast(value) }

    context "with nil" do
      let(:value) { nil }
      it { should be_nil }
    end

    context "with an array" do
      context "which is empty" do
        let(:value) { [] }
        it { should be_empty }
      end

      context "which contains unique values" do
        let(:value) { %w[a b] }
        it { should == Set.new(value) }
      end

      context "which does not contain unique values" do
        let(:value) { %w[a a] }
        it { should == Set.new(value) }
      end
    end

    context "with a set" do
      let(:value) { Set.new(%w[a b]) }
      it { should == value }
    end
  end

  describe "#serialize" do
    subject { type.serialize(set) }

    context "with nil" do
      let(:set) { nil }
      it { should be_nil }
    end

    context "with a set" do
      context "which is empty" do
        let(:set) { Set.new }
        it { should be_empty }
      end

      context "which is not empty" do
        let(:set) { Set.new(%w[b a]) }
        it { should == %w[a b] }
      end
    end
  end
end

