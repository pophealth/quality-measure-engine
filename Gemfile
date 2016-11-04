source 'https://rubygems.org'

# Specify your gem's dependencies in quality-measure-engine.gemspec
gemspec

group :test do
  gem 'codeclimate-test-reporter', require: false
end

gem(
  'delayed_job_mongoid',
  git: 'git@github.com:q-centrix/delayed_job_mongoid',
  # path: '../q-centrix-delayed-job-mongoid'
  branch: 'chores/upgrade_rails_5'
)

# gem 'pry', require: false
# gem 'pry-nav', require: true
# gem 'pry-rescue', require: true
# gem 'pry-stack_explorer', require: true
