require 'sinatra/base'
require 'erb'
require 'ostruct'
MEASURE_DIR = ENV['MEASURE_DIR'] || 'measures'
puts MEASURE_DIR
# if ARGV[0]
#   if File.exists? ARGV[0]
#     if ARGV[0][-1] == '/'
#       MEASURE_DIR = ARGV[0].chop
#     else
#       MEASURE_DIR = ARGV[0]
#     end
#   else
#     raise "Could not find the measure directory #{ARGV[0]}"
#   end
# else
#   raise "Please specify the directory where the measures are located"
# end



class MapTest < Sinatra::Base
  set :public, File.dirname(__FILE__) + '/public'
  set :views, File.dirname(__FILE__) + '/views'
  
  get '/' do
    measures = Dir.glob(MEASURE_DIR + '/measures/*').map {|m| File.basename(m)}
    erb :index, :locals => {:measures => measures}
  end
  
  get '/measures/:id/test_page' do |measure_id|
    javascripts = []
    patients = []
    
    Dir.glob(MEASURE_DIR + '/js/*.js').each do |js_file|
      javascripts << File.basename(js_file)
    end
    
    Dir.glob(File.dirname(__FILE__) + '/../js/*.js').each do |js_file|
      javascripts << File.basename(js_file)
    end
    
    Dir.glob(MEASURE_DIR + '/fixtures/measures/' + measure_id +'/patients/*.json').each do |json_file|
      patients << File.basename(json_file)
    end
    
    raw_js = File.read(MEASURE_DIR + '/measures/' + measure_id + '/' + params[:script])
    template = ERB.new(raw_js)
    template_params = OpenStruct.new
    template_params.effective_date = params[:effective_time].to_i
    mapper_function = template.result(template_params.instance_eval { binding })
    
    erb :test_page, :locals => {:javascripts => javascripts, :measure_id  => measure_id,
                                :mapper_function => mapper_function, :patients => patients}
  end
  
  get '/qme_js/:js' do |js|
    if File.exists?(MEASURE_DIR + '/js/' + js)
      send_file MEASURE_DIR + '/js/' + js
    elsif File.exists?(File.dirname(__FILE__) + '/../js/' + js)
      send_file File.dirname(__FILE__) + '/../js/' + js
    else
      halt 404
    end
  end
  
  get '/patients/:id/:record' do |measure_id, record|
    send_file (MEASURE_DIR + '/fixtures/measures/' + measure_id + '/patients/' + record)
  end
  
  get '/measures/:id' do |measure_id|
    javascripts = []
    if Dir.exists?(MEASURE_DIR + '/measures/' + measure_id + '/components')
      Dir.glob(MEASURE_DIR + '/measures/' + measure_id + '/components/*.js').each do |js_file|
        relative_file_name = 'components/' + File.basename(js_file)
        javascripts << relative_file_name
      end
    else
      Dir.glob(MEASURE_DIR + '/measures/' + measure_id + '/*.js').each do |js_file|
        javascripts << File.basename(js_file)
      end
    end
    
    erb :map_select, :locals => {:javascripts => javascripts, :measure_id  => measure_id}
  end
end

MapTest.run!
