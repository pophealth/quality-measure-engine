require 'rspec/core/rake_task'
require 'jeweler'
require 'yard'

Dir['lib/tasks/*.rake'].sort.each do |ext|
  load ext
end

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/**/*_spec.rb'
end

Jeweler::Tasks.new do |gem|
  gem.name = "quality-measure-engine"
  gem.summary = "A library for extracting quality measure information from HITSP C32's and ASTM CCR's"
  gem.description = "A library for extracting quality measure information from HITSP C32's and ASTM CCR's"
  gem.email = "talk@projectpophealth.org"
  gem.homepage = "http://github.com/pophealth/quality-measure-engine"
  gem.authors = ["Marc Hadley", "Andy Gregorowicz"]
  
  gem.add_dependency 'mongo', '~> 1.1'
  gem.add_dependency 'therubyracer', '~> 0.7.5'
  
  gem.add_development_dependency "jsonschema", "~> 2.0.0"
  gem.add_development_dependency "rspec", "~> 2.0.0"
  gem.add_development_dependency "awesome_print", "~> 0.2.1"
  gem.add_development_dependency "jeweler", "~> 1.4.0"
end

YARD::Rake::YardocTask.new
