# frozen_string_literal: true

require "rails/boost"
require "rails/boost/active_record/type/set"
require "pg"

RSpec.describe Rails::Boost::ActiveRecord::Type::Set do
  let(:type) { described_class.new(array_type) }
  let(:array_type) { ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Array.new(text_type) }
  let(:text_type) { ActiveRecord::Type::Text.new }

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

    context "with a nonsense value" do
      let(:value) { "not a set" }
      it { should == value }
    end

    context "with a PostgreSQL array literal string" do
      let(:value) { "{a,b,c}" }
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
        it { should be_an(ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Array::Data) }
        its(:values) { should be_empty }
      end

      context "which is not empty" do
        let(:set) { Set.new(%w[b a]) }
        it { should be_an(ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Array::Data) }
        its(:values) { should == set.sort }
      end

      context "with multiple values that cast to the same value" do
        let(:set) { Set.new([1, "1"]) }
        it { should be_an(ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Array::Data) }
        its(:values) { should == ["1"] }
      end
    end
  end

  describe "#deserialize" do
    subject { type.deserialize(database_string) }

    context "with nil" do
      let(:database_string) { nil }
      it { should be_nil }
    end

    context "with an empty array" do
      let(:database_string) { "{}" }
      it { should == Set.new([]) }
    end

    context "with an array with string values" do
      let(:database_string) { "{a,b,c}" }
      it { should == Set.new(%w[a b c]) }
    end
  end
end

