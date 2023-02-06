# frozen_string_literal: true

require "active_storage/service/s3_service"

# Add the ability to specify a content_encoding value when attaching files via
# an ActiveStorage attachment.
#
# This augmentation does not change the functionality of the service object, it
# only adds the `content_encoding` keyword argument to the #upload method (and
# the subordinate methods #upload_with_single_part and #upload_with_multipart).
#
# See the augmentation of the ActiveStorage::Blob class for usage details.

module Rails::Boost
  module ActiveStorage
    module Service
      module S3Service
        module ContentEncoding
          def upload(key, io, checksum: nil, filename: nil, content_type: nil, content_encoding: nil, disposition: nil, custom_metadata: {}, **)
            instrument(:upload, key:, checksum:) do
              content_disposition = content_disposition_with(filename:, type: disposition) if disposition && filename

              if io.size < multipart_upload_threshold
                upload_with_single_part(key, io, checksum:, content_type:, content_disposition:, content_encoding:, custom_metadata:)
              else
                upload_with_multipart(key, io, content_type:, content_encoding:, content_disposition:, custom_metadata:)
              end
            end
          end

          private

          def upload_with_single_part(key, io, checksum: , content_type: , content_encoding: , content_disposition: , custom_metadata: )
            object_for(key).put(body: io, content_md5: checksum, content_type:, content_encoding:, content_disposition:, metadata: custom_metadata, **upload_options)
          rescue Aws::S3::Errors::BadDigest
            raise ActiveStorage::IntegrityError
          end

          def upload_with_multipart(key, io, content_type: , content_encoding: , content_disposition: , custom_metadata: )
            part_size = [io.size.fdiv(MAXIMUM_UPLOAD_PARTS_COUNT).ceil, MINIMUM_UPLOAD_PART_SIZE].max

            object_for(key).upload_stream(content_type:, content_encoding:, content_disposition:, part_size:, metadata: custom_metadata, **upload_options) do |out|
              IO.copy_stream(io, out)
            end
          end
        end
      end
    end
  end
end

