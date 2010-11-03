require 'bundler/setup'

PROJECT_ROOT = File.dirname(__FILE__) + '/../'

require PROJECT_ROOT + 'lib/quality-measure-engine'
require PROJECT_ROOT + 'lib/tasks/database-loader'

Bundler.require(:test)
