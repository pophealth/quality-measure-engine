require 'mongo'
require 'json'
require './lib/tasks/database-loader'

measure_dir = ENV['MEASURE_DIR'] || 'measures'
loader = QME::Database::Loader.new('test')

namespace :mongo do

  desc 'Remove the patient records collection'
  task :drop_records do
    loader.drop_collection('records')
  end

  desc 'Remove the measures collection'
  task :drop_measures do
    loader.drop_collection('measures')
  end
  
  desc 'Remove all measures and reload'
  task :reload_measures => :drop_measures do
    # load static measure files
    load_measure_files(loader, File.join(measure_dir, '*'), 'measures')
    
    # load composite measure files
    Dir.glob(File.join(measure_dir, '*', '*.col')).each do |file|
      component_dir = File.join(File.dirname(file), 'components')
      loader.create_collection(file, component_dir).each do |measure|
        loader.save('measures', measure)
      end
    end
  end
  
  desc 'Remove all patient records and reload'
  task :reload_records => :drop_records do
    load_files(loader, File.join(measure_dir,'*','patients','*.json'), 'records')
  end

  desc 'Clear database and road each measure and its sample patient files'
  task :reload => [:reload_records, :reload_measures]
  
  def load_files(loader, file_pattern, collection_name)
    Dir.glob(file_pattern).each do |file|
      json = JSON.parse(File.read(file))
      loader.save(collection_name, json)
    end
  end

  def load_measure_files(loader, dir_pattern, collection_name)
    Dir.glob(dir_pattern).each do |dir|
      files = Dir.glob(File.join(dir,'*.json'))
      if files.length==1
        measure_file = files[0]
        files = Dir.glob(File.join(dir,'*.js'))
        if files.length!=1
          raise "Unexpected number of map functions in #{dir}, expected 1"
        end
        map_file = files[0]
        measure = loader.load_measure(measure_file, map_file)
        loader.save(collection_name, measure)
      end
    end
  end
end
