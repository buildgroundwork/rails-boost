# frozen_string_literal: true

require "active_support/core_ext/string/inflections"
require "active_support/core_ext/hash/indifferent_access"
require "rails/boost/active_support/hash_with_indifferent_access/opinionated_keys"

# rubocop:disable RSpec/FilePath
RSpec.describe ActiveSupport::HashWithIndifferentAccess do
  let(:hwia) { described_class.new(a: 1, "b" => 2, c: { x: 1, "y" => 2 }) }
  before(:all) do
    ::ActiveSupport::HashWithIndifferentAccess.instance_eval do
      prepend Rails::Boost::ActiveSupport::HashWithIndifferentAccess::OpinionatedKeys
    end
  end

  describe "#to_hash" do
    subject { hwia.to_hash }

    its(:keys) { should == %i[a b c] }
    its([:c]) { should == { x: 1, y: 2 } }
  end

  describe "#transform_keys" do
    subject { hwia.transform_keys(&:titleize) }
    its(:keys) { should == %w[A B C] }
  end

  describe "#transform_keys!" do
    subject { hwia }
    before { hwia.transform_keys!(&:titleize) }
    its(:keys) { should == %w[A B C] }
  end

  describe "#deep_transform_keys" do
    subject { hwia.deep_transform_keys(&:titleize) }
    its([:C]) { should == { "X" => 1, "Y" => 2 } }
  end

  describe "#deep_transform_keys!" do
    subject { hwia }
    before { hwia.deep_transform_keys!(&:titleize) }
    its([:C]) { should == { "X" => 1, "Y" => 2 } }
  end
end
# rubocop:enable RSpec/FilePath

