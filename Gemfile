source "http://rubygems.org"

gemspec :development_group => :test

gem 'mongo', '1.5.1'
gem 'bson_ext', '1.5.1',  :platforms => :mri
gem 'rake'
gem 'pry', :require => true

group :test do
  gem 'cover_me', '>= 1.0.0.rc5', :platforms => :ruby_19
  gem 'metric_fu'
  gem 'sinatra'
end

group :build do
  gem 'yard'
  gem 'kramdown' # needed by yard
end
