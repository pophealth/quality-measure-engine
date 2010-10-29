require 'mongo'
require 'json'

measure_dir = ENV['MEASURE_DIR'] || 'measures'
db_host = ENV['TEST_DB_HOST'] || 'localhost'
db_port = ENV['TEST_DB_PORT'] ? ENV['TEST_DB_PORT'].to_i : 27017
db = Mongo::Connection.new(db_host, db_port).db('test')

namespace :mongo do

  desc 'Remove the patient records collection'
  task :drop_records do
    db.drop_collection('records')
  end

  desc 'Remove the measures collection'
  task :drop_measures do
    db.drop_collection('measures')
  end
  
  desc 'Remove all measures and reload'
  task :reload_measures => :drop_measures do
    load_files(db, File.join(measure_dir,'*','*.json'), 'measures')
  end
  
  desc 'Remove all patient records and reload'
  task :reload_records => :drop_records do
    load_files(db, File.join(measure_dir,'*','patients','*.json'), 'records')
  end

  desc 'Clear database and road each measure and its sample patient files'
  task :reload => [:reload_records, :reload_measures]
  
  def load_files(db, file_pattern, collection_name)
    collection = db.create_collection(collection_name)
    Dir.glob(file_pattern).each do |file|
      json = JSON.parse(File.read(file))
      collection.save(json)
    end
  end

end
