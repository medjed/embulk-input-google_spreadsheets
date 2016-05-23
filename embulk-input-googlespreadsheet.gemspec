Gem::Specification.new do |spec|
  spec.name          = "embulk-input-googlespreadsheet"
  spec.version       = "0.2.0"
  spec.authors       = ["yang-xu"]
  spec.summary       = "Googlespreadsheet input plugin for Embulk"
  spec.description   = "Fetches data from Googlespreadsheet."
  spec.email         = ["xu.yang.9.65@gmail.com"]
  spec.licenses      = ["MIT"]
  spec.homepage      = "https://github.com/apollocarlos/embulk-input-googlespreadsheet"

  spec.files         = `git ls-files`.split("\n") + Dir["classpath/*.jar"]
  spec.test_files    = spec.files.grep(%r{^(test|spec)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'embulk', ['> 0.8.1']
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency "bundler-dena"
  spec.add_development_dependency 'rake'

  spec.add_runtime_dependency "google_drive", ">= 2.0.0.beta"
  spec.add_runtime_dependency "signet"
  spec.add_runtime_dependency "tzinfo"
end
