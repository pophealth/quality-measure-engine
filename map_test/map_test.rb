require 'sinatra/base'
require 'erb'
require 'ostruct'

class MapTest < Sinatra::Base
  set :public, File.dirname(__FILE__) + '/public'
  set :views, File.dirname(__FILE__) + '/views'
  
  get '/' do
    measures = Dir.glob(File.dirname(__FILE__) + '/../measures/*').map {|m| File.basename(m)}
    erb :index, :locals => {:measures => measures}
  end
  
  get '/measures/:id/test_page' do |measure_id|
    javascripts = []
    patients = []
    Dir.glob(File.dirname(__FILE__) + '/../js/*.js').each do |js_file|
      javascripts << File.basename(js_file)
    end
    
    Dir.glob(File.dirname(__FILE__) + '/../measures/' + measure_id +'/patients/*.json').each do |json_file|
      patients << File.basename(json_file)
    end
    
    raw_js = File.read(File.dirname(__FILE__) + '/../measures/' + measure_id + '/' + params[:script])
    template = ERB.new(raw_js)
    template_params = OpenStruct.new
    template_params.effective_date = params[:effective_time].to_i
    mapper_function = template.result(template_params.instance_eval { binding })
    
    erb :test_page, :locals => {:javascripts => javascripts, :measure_id  => measure_id,
                                :mapper_function => mapper_function, :patients => patients}
  end
  
  get '/qme_js/:js' do |js|
    send_file File.dirname(__FILE__) + '/../js/' + js
  end
  
  get '/patients/:id/:record' do |measure_id, record|
    send_file (File.dirname(__FILE__) + '/../measures/' + measure_id + '/patients/' + record)
  end
  
  get '/measures/:id' do |measure_id|
    javascripts = []
    if Dir.exists?(File.dirname(__FILE__) + '/../measures/' + measure_id + '/components')
      Dir.glob(File.dirname(__FILE__) + '/../measures/' + measure_id + '/components/*.js').each do |js_file|
        relative_file_name = 'components/' + File.basename(js_file)
        javascripts << relative_file_name
      end
    else
      Dir.glob(File.dirname(__FILE__) + '/../measures/' + measure_id + '/*.js').each do |js_file|
        javascripts << File.basename(js_file)
      end
    end
    
    erb :map_select, :locals => {:javascripts => javascripts, :measure_id  => measure_id}
  end
end

MapTest.run!
