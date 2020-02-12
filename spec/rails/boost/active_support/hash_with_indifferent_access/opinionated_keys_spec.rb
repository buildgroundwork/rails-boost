# frozen_string_literal: true

require 'spec_helper'

require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/hash/indifferent_access'
require_relative '../../../../../lib/rails/boost/version'
require_relative '../../../../../lib/rails/boost/active_support/hash_with_indifferent_access/opinionated_keys'

RSpec.describe ActiveSupport::HashWithIndifferentAccess do
  let(:hwia) { described_class.new(a: 1, "b" => 2, c: { x: 1, "y" => 2 }) }
  before do
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
    its(:keys) { should == %i[A B C] }
  end
end

