# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "quality-measure-engine"
  s.summary = "A library for extracting quality measure information from HITSP C32's and ASTM CCR's"
  s.description = "A library for extracting quality measure information from HITSP C32's and ASTM CCR's"
  s.email = "talk@projectpophealth.org"
  s.homepage = "http://github.com/pophealth/quality-measure-engine"
  s.authors = ["Marc Hadley", "Andy Gregorowicz", "Rob Dingwell"]
  s.version = '1.1.4'
  
  s.add_dependency 'mongo', '~> 1.3'
  s.add_dependency 'rubyzip', '~> 0.9.4'
  s.add_dependency 'nokogiri', '>= 1.4.4'
  s.add_dependency 'resque', '~> 1.15.0'
  s.add_dependency 'resque-status', '~> 0.2.3'
  
  s.add_development_dependency "jsonschema", "~> 2.0.0"
  s.add_development_dependency "rspec", "~> 2.5.0"
  s.add_development_dependency "awesome_print", "~> 0.3"
  s.add_development_dependency "roo", "~> 1.9.3"
  s.add_development_dependency "builder", "~> 3.0.0"
  s.add_development_dependency "spreadsheet", "~> 0.6.5.2"
  s.add_development_dependency "google-spreadsheet-ruby", "~> 0.1.2"

  s.files = Dir.glob('lib/**/*.rb') + Dir.glob('lib/**/*.rake') +
            Dir.glob('js/**/*.js*') + Dir.glob('spec/**/*.rb') + ["Gemfile", "README.md", "Rakefile", "VERSION"]
end

