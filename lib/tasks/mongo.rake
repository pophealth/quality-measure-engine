path = File.dirname(__FILE__)
path = path.index('lib') == 0 ? "./#{path}" : path
require 'mongo'
require 'json'
require File.join(path,'../quality-measure-engine')


measures_dir = ENV['MEASURE_DIR'] || 'measures'
bundle_dir = ENV['BUNDLE_DIR'] || '.'
fixtures_dir = ENV['FIXTURE_DIR'] || File.join('fixtures', 'measures')
loader = QME::Database::Loader.new('test')

namespace :mongo do

  desc 'Remove the patient records collection'
  task :drop_records do
    loader.drop_collection('records')
  end

  desc 'Remove all patient records and reload'
  task :drop_bundle  do
    loader.drop_collection('bundles')
    loader.drop_collection('measures')
  end
  
  desc 'Remove the measures collection'
  task :drop_measures do
    loader.drop_collection('measures')
  end
  
  desc 'Remove all measures and reload'
  task :reload_measures => :drop_measures do
    Dir.glob(File.join(measures_dir, '*')).each do |measure_dir|
      loader.save_measure(measure_dir, 'measures')
    end
  end
  
  desc 'Remove all patient records and reload'
  task :reload_records => :drop_records do
    load_files(loader, File.join(fixtures_dir,'*','patients','*.json'), 'records')
  end

  desc 'Remove all patient records and reload'
  task :reload_bundle => [:drop_bundle] do
   loader.save_bundle(bundle_dir,'bundles')
  end
  
  desc 'Clear database and road each measure and its sample patient files'
  task :reload => [:reload_records, :reload_measures]
  
  def load_files(loader, file_pattern, collection_name)
    Dir.glob(file_pattern).each do |file|
      json = JSON.parse(File.read(file))
      loader.save(collection_name, json)
    end
  end
  
end
