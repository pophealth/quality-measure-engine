require 'json'
require './lib/quality-measure-engine'
require './lib/tasks/measure_loader'

measures_dir = ENV['MEASURE_DIR'] || 'measures'

namespace :measures do
  
  desc 'Build all measures to tmp directory'
  task :build do
    dest_dir = File.join('.', 'tmp')
    Dir.mkdir(dest_dir) if !Dir.exist?(dest_dir)
    Dir.glob(File.join(measures_dir, '*')).each do |measure_dir|
      measures = QME::Measure::Loader.load_measure(measure_dir)
      measures.each do |measure|
        id = measure['id']
        sub_id = measure['sub_id']
        json = JSON.pretty_generate(measure)
        file_name = File.join(dest_dir, "#{id}#{sub_id}.json")
        file = File.new(file_name,  "w")
        file.write(json)
        file.close
      end
    end
  end

end
