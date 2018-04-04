require_relative 'lib/deleted_at/version'

Gem::Specification.new do |spec|
  spec.name          = "deleted_at"
  spec.version       = DeletedAt::VERSION
  spec.authors       = ['Dale Stevens']
  spec.email         = ['dale@twilightcoders.net']

  spec.summary       = %q{Soft delete your data, but keep it clean.}
  spec.description   = %q{Default scopes are bad. Don't delete your data. DeletedAt, I choose you!}
  spec.homepage      = "https://github.com/TwilightCoders/deleted_at"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = Dir['CHANGELOG.md', 'README.md', 'LICENSE', 'lib/**/*']
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  rails_versions = ['>= 4.1', '< 6']
  spec.required_ruby_version = '>= 2.3'

  spec.add_runtime_dependency 'activerecord', rails_versions

  spec.add_development_dependency 'pg', '~> 0'
  spec.add_development_dependency 'pry-byebug', '~> 3'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'combustion', '~> 0.7'

end
