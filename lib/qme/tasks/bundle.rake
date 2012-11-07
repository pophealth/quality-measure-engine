require 'quality-measure-engine'

db_name = ENV['DB_NAME'] || 'test'

namespace :bundle do
  desc 'Import a quality bundle into the database.'
  task :import, :bundle_path, :delete_existing, :needs => :environment do |task, args|
    raise "The path to the measures zip file must be specified" unless args.bundle_path

    bundle = File.open(args.bundle_path)    
    importer = QME::Bundle::Importer.new(db_name)
    bundle_contents = importer.import(bundle, args.delete_existing == "true")
    
    puts "Successfully imported bundle at: #{args.bundle_path}"
    puts "\t Imported into environment: #{Rails.env.upcase}" if defined? Rails 
    puts "\t Measures Loaded: #{bundle_contents[:measures].count}"
    puts "\t Test Patients Loaded: #{bundle_contents[:patients].count}"
    puts "\t Extensions Loaded: #{bundle_contents[:extensions].count}"
    
  end
end
