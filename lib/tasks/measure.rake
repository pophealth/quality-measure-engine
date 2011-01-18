path = File.dirname(__FILE__)
path = path.index('lib') == 0 ? "./#{path}" : path
require 'json'
require 'zlib'
require File.join(path,'../quality-measure-engine')


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
  
  
  desc "bundle measures into a compressed file for deployment"
  task :bundle do
    path = measures_dir
      gem 'rubyzip'
      require 'zip/zip'
      require 'zip/zipfilesystem'

      path.sub!(%r[/$],'')
      archive = File.join(path,File.basename(path))+'.zip'
      FileUtils.rm archive, :force=>true

      Zip::ZipFile.open(archive, 'w') do |zipfile|
        Dir["#{path}/**/**"].reject{|f|f==archive}.each do |file|
          zipfile.add(file.sub(path+'/',''),file)
        end
      end
  end
  
  
  desc "bundle measures into a compressed file for deployment"
  task :unbundle do
    path = measures_dir
    path.sub!(%r[/$],'')
    archive = File.join(path,File.basename(path))+'.zip'
    puts QME::Measure::Loader.load_from_zip(archive)
  end
end
