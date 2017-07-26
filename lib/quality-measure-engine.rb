require "bundler/setup"

require 'delayed_job_mongoid'
require 'zip/zip'

require "qme/version"
require 'qme/database_access'
require 'qme/quality_measure'
require 'qme/quality_report'
require 'qme/patient_cache'
require 'qme/manual_exclusion'

require 'qme/map/effective_start_date_injector'
require 'qme/map/map_reduce_builder'
require 'qme/map/map_reduce_executor'
require 'qme/map/measure_calculation_job'
require 'qme/map/cv_aggregator'




require 'qme/railtie' if defined?(Rails)