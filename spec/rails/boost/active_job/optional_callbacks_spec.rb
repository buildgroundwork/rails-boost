# frozen_string_literal: true

require "active_job"
require "rails/boost"
require "rails/boost/active_job/optional_callbacks"

class OptionalCallbacksTestJob < ActiveJob::Base
  def initialize(*, **)
    @callback_ran = false
    super
  end

  attr_reader :callback_ran

  after_enqueue { @callback_ran = true }
end

RSpec.describe Rails::Boost::ActiveJob::OptionalCallbacks do
  before(:all) do
    mod = described_class
    ActiveJob::Base.instance_eval { prepend mod }
  end

  describe "callbacks" do
    subject { job.callback_ran }
    let(:job) { OptionalCallbacksTestJob.perform_later(**kwargs) }

    context "when enqueuing a job without the callbacks keyword argument" do
      let(:kwargs) { {} }

      context "when callbacks are disabled via environment variable" do
        before { allow(ENV).to receive(:fetch).with("ACTIVE_JOB_DISABLE_CALLBACKS", false).and_return("true") }
        it { should_not be_truthy }
      end

      context "when callbacks are not disabled via environment variable" do
        it { should be_truthy }
      end
    end

    context "when enqueuing a job with callbacks: false" do
      let(:kwargs) { { callbacks: false } }
      it { should_not be_truthy }
    end

    context "when enqueuing a job with callbacks: true" do
      let(:kwargs) { { callbacks: true } }
      it { should be_truthy }
    end
  end
end

