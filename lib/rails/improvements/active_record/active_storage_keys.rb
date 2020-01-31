# frozen_string_literal: true

module Rails::Improvements
  module ActiveRecord
    module ActiveStorageKeys
      def has_one_attached(name, key: nil, **remaining) # rubocop:disable Naming/PredicateName
        active_storage_keys[name.to_s] = key
        super(name, **remaining)
      end

      def active_storage_keys
        @active_storage_keys ||= {}
      end
    end
  end
end

