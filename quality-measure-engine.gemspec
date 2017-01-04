# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'qme/version'

Gem::Specification.new do |gem|
  gem.name          = "quality-measure-engine"
  gem.version       = QME::VERSION
  gem.authors       = ["Marc Hadley", "Andy Gregorowicz", "Rob Dingwell", "Adam Goldstein", "Andre Quina"]
  gem.email         = ["talk@projectpophealth.org"]
  gem.description   = %q{A library for running clinical quality measures}
  gem.summary       = %q{This library can run JavaScript based clinical quality measures on a repository of patients stored in MongoDB}
  gem.homepage      = "http://www.projectpophealth.org"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'delayed_job', ['>= 3.0', '< 5']
  gem.add_dependency 'mongoid', ['>= 3.0', '< 7']
  gem.add_dependency 'mongoid-compatibility'

  gem.add_dependency 'rubyzip', '>= 1.0.0'
  gem.add_dependency 'zip-zip'

  gem.add_dependency 'delayed_job_mongoid', '~> 2.2.0'
  gem.add_development_dependency "minitest", "~> 5.4.0"
  gem.add_development_dependency "simplecov", "~> 0.9.0"
  gem.add_development_dependency 'rails', '~> 5.0.0', '>= 5.0.0.1'
end
