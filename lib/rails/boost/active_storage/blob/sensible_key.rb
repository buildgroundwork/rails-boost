# frozen_string_literal: true

module Rails::Boost
  module ActiveStorage
    module Blob
      module SensibleKey
        class << self
          def prepended(klass)
            klass.instance_eval do
              has_one :attachment
              delegate :record, to: :attachment

              before_create :set_sensible_key
            end
          end
        end

        private

        def set_sensible_key
          if (tokenized = record.class.active_storage_keys[attachment.name])
            write_attribute(:key, substitute_tokens(tokenized))
          end
        end

        def substitute_tokens(tokenized)
          tokenized.gsub(%r{:([^/]*)}) { record.public_send(Regexp.last_match(1)) }
        end
      end
    end
  end
end

