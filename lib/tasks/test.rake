path = File.dirname(__FILE__)
path = path.index('lib') == 0 ? "./#{path}" : path
require 'mongo'
require 'json'
require File.join(path,'../quality-measure-engine')

patient_template_dir = ENV['PATIENT_TEMPLATE_DIR'] || File.join('fixtures', 'patient_templates')
db_name = ENV['DB_NAME'] || 'test'

puts patient_template_dir
namespace :patients do

  desc 'Generate n (default 10) random patient records and save them in the database'
  task :random, [:n]  do |t, args|
    n = args.n.to_i>0 ? args.n.to_i : 1
    
    templates = []
    Dir.glob(File.join(patient_template_dir, '*.json.erb')).each do |file|
      templates << File.read(file)
    end
    
    if templates.length<1
      puts "No patient templates in #{patient_template_dir}"
      return
    end
    
   

    n.times do
      template = templates[rand(templates.length)]
      puts template
      generator = QME::Randomizer::Patient.new(template)
      json = JSON.parse(generator.get())
      patient_record = QME::Importer::PatientImporter.instance.parse_hash(json)
      puts(json)
     # loader.save('records', patient_record)
    end
  end
    
end