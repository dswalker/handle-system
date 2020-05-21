# frozen_string_literal: true

require_relative 'lib/handle_system/version'

Gem::Specification.new do |spec|
  spec.name          = 'handle-system-rest'
  spec.version       = HandleSystem::VERSION
  spec.authors       = ['David Walker']
  spec.email         = ['dwalker@calstate.edu']

  spec.summary       = 'A library for interfacing with the Handle System JSON REST API.'
  spec.description   = spec.summary + ' This gem works with Handle System ' +
                       'version 8 or higher. For older versions of the ' +
                       "Handle System, which didn't have a JSON API, " +
                       'consider using the handle-system gem.'
  spec.homepage      = 'https://github.com/csuscholarworks/handle-system'
  spec.license       = 'Apache-2.0'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://github.com/csuscholarworks/handle-system/README.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'httparty', '~> 0.18'
  spec.add_development_dependency 'solargraph'
end
