require 'cover_me'
require 'bundler/setup'

PROJECT_ROOT = File.dirname(__FILE__) + '/../'

require PROJECT_ROOT + 'lib/quality-measure-engine'
require PROJECT_ROOT + 'lib/tasks/database_loader'

Bundler.require(:test)

def load_measures
  loader = QME::Database::Loader.new('test')
  measures = Dir.glob('measures/*')
  loader.drop_collection('measures')
  measures.each do |dir|
    loader.save_measure(dir, 'measures')
  end
  
  loader
end

def measure_definition(loader, measure_id, sub_id=nil)
  map = QME::MapReduce::Executor.new(loader.get_db)
  map.measure_def(measure_id, sub_id)
end