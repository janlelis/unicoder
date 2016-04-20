# -*- encoding: utf-8 -*-

require File.dirname(__FILE__) + "/lib/unicoder/constants"

Gem::Specification.new do |gem|
  gem.name          = "unicoder"
  gem.version       = Unicoder::VERSION
  gem.summary       = "Create specialized indexes for Unicode data lookup"
  gem.description   = "Generate specialized indexes for Unicode data lookup"
  gem.authors       = ["Jan Lelis"]
  gem.email         = ["mail@janlelis.de"]
  gem.homepage      = "https://github.com/janlelis/unicoder"
  gem.license       = "MIT"

  gem.files         = Dir["{**/}{.*,*}"].select{ |path| File.file?(path) && path !~ /^pkg/ }
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = "~> 2.0"
  gem.add_dependency "rationalist", "~> 2.0"
  gem.add_dependency "rubyzip", "~> 1.2"
end
