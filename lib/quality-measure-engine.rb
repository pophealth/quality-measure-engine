Bundler.require(:default)

LIB = File.dirname(__FILE__)

require LIB + '/nokogiri/namespace_context'

require LIB + '/qme/map/map_reduce_builder'
require LIB + '/qme/map/map_reduce_executor'

require 'singleton'

require LIB + '/qme/importer/patient_importer'

require 'json'
require 'mongo'
