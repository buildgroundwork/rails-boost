# frozen_string_literal: true

require "active_storage"
require "io/like"

module Rails::Boost
  module ActiveStorage
    class IO
      include ::IO::Like

      def initialize(blob)
        @blob = blob
        @pos = 0
      end

      # The IO::Like module does not handle calls to #gets with a limit
      # parameter.  This ignores this second parameter, which means this won't
      # necessarily return the correct amount of content, but it also won't
      # throw an argument error.
      def gets(separator = $INPUT_RECORD_SEPARATOR, _limit = nil)
        super(separator)
      end

      def unbuffered_read(length)
        raise EOFError if @eof

        range = @pos...(@pos + length)

        @blob.service.download_chunk(@blob.key, range).tap do |content|
          @eof = true if content.length < length
          @pos += content.length
        end
      end

      def unbuffered_seek(offset, whence)
        @eof = false
        @pos = (
          case whence
          when ::IO::SEEK_SET then offset
          when ::IO::SEEK_CUR then @pos + offset
          else raise ArgumentError
          end
        )
      end
    end
  end
end

