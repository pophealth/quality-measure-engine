Bundler.require(:default)

LIB = File.dirname(__FILE__)

require LIB + '/qme/map/map_reduce_builder'
require LIB + '/qme/map/map_reduce_executor'

require 'singleton'

require LIB + '/qme/importer/patient_importer'
require LIB + '/qme/importer/code_system_helper'
require LIB + '/qme/importer/hl7_helper'

require LIB + '/qme/importer/section_importer'
require LIB + '/qme/importer/generic_importer'

require LIB + '/qme/mongo_helpers'

require 'json'
require 'mongo'


module QME
  def self.load_tasks
    puts "loading"
  end
end