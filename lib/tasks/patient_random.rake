path = File.dirname(__FILE__)
path = path.index('lib') == 0 ? "./#{path}" : path
require 'mongo'
require 'json'
require File.join(path,'../quality-measure-engine')

patient_template_dir = ENV['PATIENT_TEMPLATE_DIR'] || File.join('fixtures', 'patient_templates')
db_name = ENV['DB_NAME'] || 'test'
loader = QME::Database::Loader.new(db_name)

namespace :patient do

  desc 'Generate n (default 10) random patient records and save them in the database'
  task :random, :n do |t, args|
    n = args.n.to_i>0 ? args.n.to_i : 10
    
    templates = []
    Dir.glob(File.join(patient_template_dir, '*.json.erb')).each do |file|
      templates << File.read(file)
    end
    
    n.times do
      template = templates[rand(templates.length)]
      generator = QME::Randomizer::Patient.new(template)
      save(loader, 'records', generator.get())
    end
  end
    
  def save(loader, collection_name, record)
    json = JSON.parse(record)
    loader.save(collection_name, json)
  end
  
end
