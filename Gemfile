source "http://rubygems.org"

gemspec :development_group => :test

gem 'mongo', '1.5.1'
gem 'bson_ext', '1.5.1',  :platforms => :mri
gem 'rake'
#gem 'pry', :require => true
gem 'health-data-standards', :git => 'https://github.com/projectcypress/health-data-standards.git', :branch => 'develop'
#gem 'health-data-standards', '0.8.0'

# does not work with redis 3.0
gem 'redis', '~> 2.2.2'

group :test do
  gem 'cover_me', '>= 1.0.0.rc5', :platforms => :ruby_19
  gem 'sinatra'
end

group :build do
  gem 'yard'
  gem 'kramdown' # needed by yard
end
