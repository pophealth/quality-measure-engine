require 'rspec/core/rake_task'
require 'jeweler'

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

desc 'Load all the measures and sample patient files into the database'
task :loaddb do
  require './spec/spec_helper'
  db_host = nil
  if ENV['TEST_DB_HOST']
    db_host = ENV['TEST_DB_HOST']
  else
    db_host = 'localhost'
  end
  db = Mongo::Connection.new(db_host, 27017).db('test')
  
  db.drop_collection('measures')
  db.drop_collection('records')

  measures = Dir.glob('measures/*')
  measures.each do |dir|
    # load db with measure and sample patient records
    files = Dir.glob(File.join(dir,'*.json'))
    measure_file = files[0]
    patient_files = Dir.glob(File.join(dir, 'patients', '*.json'))
    measure = JSON.parse(File.read(measure_file))
    measure_id = measure['id']
    measure_collection = db.create_collection('measures')
    record_collection = db.create_collection('records')
    measure_collection.save(measure)
    patient_files.each do |patient_file|
      patient = JSON.parse(File.read(patient_file))
      record_collection.save(patient)
    end
  end
end
