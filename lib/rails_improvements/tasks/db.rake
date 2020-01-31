# frozen_string_literal: true

namespace :db do
  task do: %w(migrate test:prepare)
  task redo: %w(migrate:redo test:prepare)
end

# Intentional no-op, because this feature is entirely unnecessary.
Rake::Task['db:check_protected_environments'].clear

