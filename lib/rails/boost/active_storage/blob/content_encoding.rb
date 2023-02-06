# frozen_string_literal: true

# Add the ability to specify a content_encoding value when attaching files via
# an ActiveStorage attachment.
#
# This augmentation combines with the augementation of the S3 storage service
# class to allow attaching a file like this:
#
#   record.update!(some_attachment: {
#     io: gzipped_content,
#     content_type: "text/csv",
#     content_encoding: "gzip",    # <== added option
#     filename: "wibble.csv"
#   })
#
# This will work only with content attached as a Hash; ActiveStorage builds
# blobs differently for uploaded files.

module Rails::Boost
  module ActiveStorage
    module Blob
      module ContentEncoding
        class << self
          # rubocop:disable Style/MethodCallWithArgsParentheses
          def prepended(klass)
            klass.instance_eval do
              attribute :content_encoding, :string

              klass.singleton_class.instance_eval do
                prepend ClassMethods
              end
            end
          end
          # rubocop:enable Style/MethodCallWithArgsParentheses
        end

        module ClassMethods
          # This override does not change the functionality of the method, only
          # the parameters signature.  Rather than naming each keyword argument
          # explicitly it passes all keyword arguments along to the initializer.
          # This allows passing additional attributes (e.g. the `content_encoding`
          # defined above.
          # rubocop:disable Lint/UnusedMethodArgument
          def build_after_unfurling(io: , record: nil, identify: true, **kwargs)
            new(kwargs).tap { |blob| blob.unfurl(io, identify:) }
          end
          # rubocop:enable Lint/UnusedMethodArgument
        end

        private

        def service_metadata
          super.merge(content_encoding:)
        end
      end
    end
  end
end

