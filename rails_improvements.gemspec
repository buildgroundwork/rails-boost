# frozen_string_literal: true

require_relative 'lib/rails_improvements/version'

Gem::Specification.new do |spec|
  spec.name          = 'rails_improvements'
  spec.version       = RailsImprovements::VERSION
  spec.authors       = ['Grant Hutchins', 'Adam Milligan']
  spec.email         = ['gems@nertzy.com', 'adam@buildgroundwork.com']

  spec.summary       = 'Improvements to Rails'
  spec.description   = 'Improvements to Rails'
  spec.homepage      = 'https://github.com/StrongholdResourcePartners/rails_improvements'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  # spec.metadata['changelog_uri'] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_development_dependency('rubocop')
  spec.add_development_dependency('rake')
end

