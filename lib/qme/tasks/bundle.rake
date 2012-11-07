require 'quality-measure-engine'

db_name = ENV['DB_NAME'] || 'test'

namespace :bundle do
  desc 'Import a quality bundle into the database.'
  task :import, :bundle_path, :delete_existing, :needs => :environment do |task, args|
    raise "The path to the measures zip file must be specified" unless args.bundle_path

    bundle = File.open(args.bundle_path)    
    importer = QME::Bundle::Importer.new(db_name)
    importer.import(bundle, args.delete_existing == "true")
  end
end