# frozen_string_literal: true

# ActiveJob runs callbacks when a job is enqueued. If there is a callback, then the callback is
# `instance_exec`ed on the job instance, which creates its singleton class. We have observed that
# this singleton class is not getting garbage collected after the job instance falls out of scope.
#
# This change allows the caller to decide to skip callbacks by passing `callbacks: false` as a keyword
# argument when initializing a job, such as when ActiveJob::Base.perform_later is called.
#
# Note that Active Job uses a callback to log a message when a job is enqueued. Disabling callbacks will
# skip this logging functionality.
module Rails::Boost
  module ActiveJob
    module OptionalCallbacks
      def initialize(*args, callbacks: !ENV.fetch("ACTIVE_JOB_DISABLE_CALLBACKS", false), **kwargs)
        @rails_boost_callbacks = callbacks
        super(*args, **kwargs)
      end

      def run_callbacks(*)
        if @rails_boost_callbacks
          super
        else
          yield if block_given?
        end
      end
    end
  end
end

