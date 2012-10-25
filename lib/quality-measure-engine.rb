require "bundler/setup"

require 'redis'
require 'resque'
require 'resque-status'
require 'moped'
require 'zip/zip'

require "qme/version"
require 'qme/database_access'
require 'qme/quality_measure'

require 'qme/map/map_reduce_builder'
require 'qme/map/map_reduce_executor'
require 'qme/map/measure_calculation_job'

require 'qme/quality_report'

require 'qme/bundle/bundle'
require 'qme/bundle/importer'

require 'qme/railtie' if defined?(Rails)