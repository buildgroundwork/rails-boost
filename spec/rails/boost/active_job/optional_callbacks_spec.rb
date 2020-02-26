# frozen_string_literal: true

require "active_job"
require "rails/boost"
require "rails/boost/active_job/optional_callbacks"

RSpec.describe Rails::Boost::ActiveJob::OptionalCallbacks do
  class Job < ActiveJob::Base
    def initialize(*)
      @callback_ran = false
      super
    end

    attr_reader :callback_ran

    after_enqueue { @callback_ran = true }
  end

  before do
    require 'rails/boost/active_job/optional_callbacks'
    ::ActiveJob::Base.instance_eval do
      prepend Rails::Boost::ActiveJob::OptionalCallbacks
    end
  end

  describe "callbacks" do
    let(:job) { Job.perform_later(**kwargs) }
    subject { job.callback_ran }

    context "after enqueuing a job without the callbacks keyword argument" do
      let(:kwargs) { {} }
      it { should be_truthy }
    end

    context "after enqueuing a job with callbacks: false" do
      let(:kwargs) { { callbacks: false } }
      it { should be_falsy }
    end

    context "after enqueuing a job with callbacks: true" do
      let(:kwargs) { { callbacks: true } }
      it { should be_truthy }
    end
  end
end

