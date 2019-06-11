require_relative 'lib/deleted_at/version'

Gem::Specification.new do |spec|
  spec.name          = "deleted_at"
  spec.version       = DeletedAt::VERSION
  spec.authors       = ['Dale Stevens']
  spec.email         = ['dale@twilightcoders.net']

  spec.summary       = %q{Soft delete your data, but keep it clean.}
  spec.description   = %q{Default scopes are bad. Don't delete your data.}
  spec.homepage      = "https://github.com/TwilightCoders/deleted_at"
  spec.license       = "MIT"

  spec.post_install_message = <<~STR
    If you're upgrading from < 0.5.0, please follow the upgrade instructions
    on #{spec.homepage}.
  STR

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.files         = Dir['CHANGELOG.md', 'README.md', 'LICENSE', 'lib/**/*']
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  rails_versions = ['>= 4.2']
  spec.required_ruby_version = '>= 2.3'

  spec.add_runtime_dependency 'activerecord', rails_versions
  spec.add_runtime_dependency 'active_record-framing', '~> 0.1.0-10'

  spec.add_development_dependency 'pg'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'combustion'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'simplecov'

end
