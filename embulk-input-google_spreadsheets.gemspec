Gem::Specification.new do |spec|
  spec.name          = 'embulk-input-google_spreadsheets'
  spec.version       = '1.1.0'
  spec.authors       = %w(Civitaspo yang-xu)
  spec.summary       = 'Google Spreadsheets input plugin for Embulk'
  spec.description   = 'Load records from Google Spreadsheets.'
  spec.email         = %w(civitaspo@gmail.com xu.yang.9.65@gmail.com)
  spec.licenses      = ['MIT']
  spec.homepage      = 'https://github.com/medjed/embulk-input-google_spreadsheets'

  spec.files         = `git ls-files`.split("\n") + Dir['classpath/*.jar']
  spec.test_files    = spec.files.grep(%r{^(test|spec)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'embulk', '>= 0.8.1'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'highline'
  spec.add_development_dependency 'test-unit'
  spec.add_development_dependency 'test-unit-rr'

  # TODO
  # signet 0.12.0 and google-api-client 0.33.0 require >= Ruby 2.4.
  # Embulk 0.9 use JRuby 9.1.X.Y and It compatible Ruby 2.3.
  # So, install signet < 0.12 and google-api-client < 0.33.0 explicitly.
  spec.add_dependency 'signet', '~> 0.7', '< 0.12'
  spec.add_dependency 'google-api-client', '>= 0.11', '< 0.33'
  spec.add_dependency 'time_with_zone'
end
