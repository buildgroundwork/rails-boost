# frozen_string_literal: true

namespace :db do
  desc "Migrate and prepare for tests"
  task do: %w[migrate test:prepare]

  desc "Rollback and migrate, then prepare for tests"
  task redo: %w[migrate:redo test:prepare]
end

# Intentional no-op, because this feature is entirely unnecessary.
Rake::Task["db:check_protected_environments"].clear

