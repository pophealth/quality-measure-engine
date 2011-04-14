path = File.dirname(__FILE__)
path = path.index('lib') == 0 ? "./#{path}" : path
require 'mongo'
require 'json'
require 'resque'
require File.join(path,'../quality-measure-engine')

measures_dir = ENV['MEASURE_DIR'] || 'measures'
bundle_dir = ENV['BUNDLE_DIR'] || '.'
fixtures_dir = ENV['FIXTURE_DIR'] || File.join('fixtures', 'measures')
db_name = ENV['DB_NAME'] || 'test'
loader = QME::Database::Loader.new(db_name)

namespace :mongo do

  desc 'Removed cached measure results'
  task :drop_cache do
    loader.drop_collection('query_cache')
    loader.drop_collection('patient_cache')
  end
  
  desc 'Remove the patient records collection'
  task :drop_records => :drop_cache do
    loader.drop_collection('records')
  end

  desc 'Remove the measures and bundles collection'
  task :drop_bundle => :drop_measures  do
    loader.drop_collection('bundles')
  end
  
  desc 'Remove the measures collection'
  task :drop_measures => :drop_cache do
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
  
  desc 'Seed the query cache by calculating the results for all measures'
  task :seed_cache, [:year, :month, :day] do |t, args|
    db = loader.get_db
    patient_cache = db['patient_cache']
    patient_cache.create_index([['value.measure_id', Mongo::ASCENDING],
                                ['value.sub_id', Mongo::ASCENDING],
                                ['value.effective_date', Mongo::ASCENDING]])
    year = args.year.to_i>0 ? args.year.to_i : 2010
    month = args.month.to_i>0 ? args.month.to_i : 9
    day = args.day.to_i>0 ? args.day.to_i : 19
    map = QME::MapReduce::Executor.new(db)
    map.all_measures.each_value do |measure_def|
      Resque.enqueue(QME::MapReduce::BackgroundWorker, measure_def['id'], measure_def['sub_id'], Time.gm(year, month, day).to_i)
    end
  end
  
  def load_files(loader, file_pattern, collection_name)
    Dir.glob(file_pattern).each do |file|
      json = JSON.parse(File.read(file))
      loader.save(collection_name, json)
    end
  end
  
end
