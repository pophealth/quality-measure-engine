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
  if sub_id
    loader.get_db['measures'].find_one(:id => measure_id, :sub_id => sub_id)
  else
    loader.get_db['measures'].find_one(:id => measure_id)
  end
end