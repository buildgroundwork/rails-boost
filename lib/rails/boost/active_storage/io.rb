# frozen_string_literal: true

require "active_storage"

module Rails::Boost
  module ActiveStorage
    class IO
      def initialize(blob)
        @blob = blob
        @pos = 0
      end

      attr_reader :pos

      def read(length)
        verify_length(length)
        eof? ? read_at_eof(length) : read_chunk(length)
      end

      def eof?
        @eof
      end

      def rewind
        self.pos = 0
      end

      def pos=(value)
        @eof = false
        @pos = value
      end

      private

      attr_reader :blob

      def verify_length(length)
        raise ArgumentError.new("no length given") if length.nil?
        raise ArgumentError.new("negative length #{length} given") if length.negative?
      end

      def read_at_eof(length)
        "" if length.zero?
      end

      def read_chunk(length)
        blob.service.download_chunk(blob.key, range_for(length)).tap do |content|
          self.pos += content.length
          @eof = true if content.length < length
        end
      end

      def range_for(length)
        pos...(pos + length)
      end
    end
  end
end

