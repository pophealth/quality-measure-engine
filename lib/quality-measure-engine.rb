Bundler.require(:default)

LIB = File.dirname(__FILE__)

require LIB + '/patches/v8'
require LIB + '/nokogiri/namespace_context'

require LIB + '/qme/map/map_reduce_builder'
require LIB + '/qme/map/map_reduce_executor'
require LIB + '/qme/query/json_document_builder'
require LIB + '/qme/query/json_query_executor'

require 'json'
require 'mongo'
require 'singleton'
