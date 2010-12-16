require 'rspec/core/rake_task'
require 'jeweler'
require 'yard'
require 'metric_fu'

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
  
  gem.add_development_dependency "jsonschema", "~> 2.0.0"
  gem.add_development_dependency "rspec", "~> 2.0.0"
  gem.add_development_dependency "awesome_print", "~> 0.2.1"
  gem.add_development_dependency "jeweler", "~> 1.4.0"
end

YARD::Rake::YardocTask.new

namespace :cover_me do
  
  task :report do
    require 'cover_me'
    CoverMe.complete!
  end
  
end

task :coverage do
  Rake::Task['spec'].invoke
  Rake::Task['cover_me:report'].invoke
end

MetricFu::Configuration.run do |config|
    #define which metrics you want to use
    config.metrics  = [:roodi, :reek, :churn, :flog, :flay]
    config.graphs   = [:flog, :flay]
    config.flay ={:dirs_to_flay => ['measures', 'lib', 'js'],
                  :minimum_score => 50,
                  :filetypes => ['rb', 'js', 'json', 'col'] }
    
end