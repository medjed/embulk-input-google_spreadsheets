Gem::Specification.new do |spec|
  spec.name          = "embulk-input-googlespreadsheet"
  spec.version       = "0.4.0"
  spec.authors       = ["yang-xu", "Civitaspo"]
  spec.summary       = "Googlespreadsheet input plugin for Embulk"
  spec.description   = "Fetches data from Googlespreadsheet."
  spec.email         = ["xu.yang.9.65@gmail.com", "civitaspo@gmail.com"]
  spec.licenses      = ["MIT"]
  spec.homepage      = "https://github.com/medjed/embulk-input-googlespreadsheet"

  spec.files         = `git ls-files`.split("\n") + Dir["classpath/*.jar"]
  spec.test_files    = spec.files.grep(%r{^(test|spec)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'embulk', '>= 0.8.1'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'

  spec.add_dependency 'google-api-client', '>= 0.10.0'
  spec.add_dependency 'tzinfo'
end
