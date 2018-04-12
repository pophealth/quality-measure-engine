source 'https://rubygems.org'

# Specify your gem's dependencies in quality-measure-engine.gemspec
gemspec

group :test do
  gem 'codeclimate-test-reporter', '< 1.0', require: false
end

gem 'pry'
gem 'pry-nav'
gem 'pry-rescue'
gem 'pry-stack_explorer'

gem(
  'delayed_job',
  git: 'git@github.com:pixeltrix/delayed_job',
  branch: 'allow-rails-5-2'
)
