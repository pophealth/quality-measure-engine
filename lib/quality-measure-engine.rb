Bundler.require(:default)

LIB = File.dirname(__FILE__)

require LIB + '/qme/map/map_reduce_builder'
require LIB + '/qme/map/map_reduce_executor'

require 'singleton'

require LIB + '/qme/importer/patient_importer'
require LIB + '/qme/importer/code_system_helper'
require LIB + '/qme/importer/hl7_helper'
require LIB + '/qme/importer/measure_base'
require LIB + '/qme/importer/diabetes_measure_base'

require LIB + '/qme/importer/generic_importer'
require LIB + '/qme/importer/section_base'

# Require all of the ruby files in the section directory
Dir.glob(File.join(LIB, 'qme', 'importer', 'section', '*.rb')).each do |measure_rb|
  require measure_rb.sub('.rb', '')
end

require LIB + '/qme/mongo_helpers'

# Require all of the ruby files in the measure directory
Dir.glob(File.join(LIB, 'qme', 'importer', 'measure', '*.rb')).each do |measure_rb|
  require measure_rb.sub('.rb', '')
end

require 'json'
require 'mongo'
